local buffer = require("string.buffer")
local ffi = require("ffi")

local math_ceil = math.ceil
local tostring = tostring
local math_floor = math.floor

local crypto = {}

crypto.cdefs = [[
	typedef enum {
		KDF_ARGON2ID,
		KDF_ARGON2D,
		KDF_ARGON2I,
	} KEY_DERIVATION_FUNCTIONS;

	struct static_crypto_exports_table {
		// OpenSSL (libcrypto) metadata
		const char* (*version_text)(void);
		long int (*version_number)(void);

		// Argon2 MCF utilities
		size_t (*openssl_to_base64)(char *dst, size_t dst_len, const char *src, size_t src_len);
		size_t (*openssl_from_base64)(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len);
		size_t (*argon2_to_base64)(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len);
		size_t (*argon2_from_base64)(char *dst, size_t dst_len, const char *src);
	};
]]

local preallocatedConversionBuffer = buffer.new(128)

function crypto.initialize()
	ffi.cdef(crypto.cdefs)

	crypto.KDF_ARGON2D = ffi.C.KDF_ARGON2D
	crypto.KDF_ARGON2I = ffi.C.KDF_ARGON2I
	crypto.KDF_ARGON2ID = ffi.C.KDF_ARGON2ID

	crypto.kdfs = {
		[ffi.C.KDF_ARGON2D] = "argon2d",
		[ffi.C.KDF_ARGON2I] = "argon2i",
		[ffi.C.KDF_ARGON2ID] = "argon2id",
	}

	crypto.DEFAULT_ARGON2_VERSION = 0x13
end

function crypto.version()
	local versionText = ffi.string(crypto.bindings.version_text())
	local sslVersion = versionText:match("OpenSSL%s(%d+%.%d+%.%d+).*")

	return sslVersion, tonumber(crypto.bindings.version_number())
end

function crypto.mcf(hash, salt, parameters)
	local mcf = string.format(
		"$%s$v=%d$m=%d,t=%d,p=%d$%s$%s",
		crypto.kdfs[parameters.kdf],
		parameters.version,
		parameters.kilobytes,
		parameters.threads,
		parameters.lanes,
		crypto.toCompactBase64(salt),
		crypto.toCompactBase64(hash)
	)

	return mcf
end

function crypto.getMaxSizeOfBase64(input)
	-- See https://www.openssl.org/docs/man3.1/man3/EVP_DecodeUpdate.html
	local OPENSSL_EVP_BLOCK_SIZE_IN_BYTES = 48
	local OPENSSL_EVP_STORAGE_SIZE_PER_BLOCK = 65 + 1 -- Output + Newline
	local numUnprocessedBytesInEncoder = 0 -- We always flush (streaming isn't supported)
	local numBlocks = math_floor((#input + numUnprocessedBytesInEncoder) / OPENSSL_EVP_BLOCK_SIZE_IN_BYTES)
	local requiredSize = (numBlocks + 1) * OPENSSL_EVP_STORAGE_SIZE_PER_BLOCK -- Flushing the last block adds one extra

	return requiredSize
end

function crypto.getSizeOfCompactBase64(input)
	-- Space requred to store one extra character in the B64 alphabet
	local BASE64_CHUNK_SIZE_IN_BITS = 6
	-- How many bytes a single 3-byte chunk will end up as when encoded
	local BASE64_BLOCK_SIZE_IN_BYTES = 4
	-- The number of complete 3-byte chunks in the input
	local blockCount = math_floor(#input / 3)
	-- How many bytes remain after the full blocks are encoded
	local numLeftoverBytes = (#input % 3)
	local numLeftoverBits = numLeftoverBytes * 8 -- 8 bits = 1 byte
	-- How many extra Base64 characters are needed to represent the leftover bits
	local numLeftoverChars = math_ceil(numLeftoverBits / BASE64_CHUNK_SIZE_IN_BITS)

	local requiredSpace = blockCount * BASE64_BLOCK_SIZE_IN_BYTES + numLeftoverChars

	return requiredSpace
end

function crypto.toCompactBase64(input)
	local requiredSpace = crypto.getSizeOfCompactBase64(input)

	preallocatedConversionBuffer:reset()
	local ptr, len = preallocatedConversionBuffer:reserve(requiredSpace)
	local numBytesWritten = crypto.bindings.argon2_to_base64(ptr, len, input, #input)
	preallocatedConversionBuffer:commit(numBytesWritten)

	return tostring(preallocatedConversionBuffer)
end

function crypto.toBase64(input)
	local requiredSpace = crypto.getMaxSizeOfBase64(input)

	preallocatedConversionBuffer:reset()
	local ptr, len = preallocatedConversionBuffer:reserve(requiredSpace)
	local numBytesWritten = crypto.bindings.openssl_to_base64(ptr, len, input, #input)
	preallocatedConversionBuffer:commit(numBytesWritten)

	return tostring(preallocatedConversionBuffer)
end

function crypto.fromCompactBase64(encodedHash)
	local requiredSpace = math_ceil(#encodedHash * 3 / 4) -- Worst case (no padding bytes)

	preallocatedConversionBuffer:reset()
	local ptr, len = preallocatedConversionBuffer:reserve(requiredSpace)
	local numBytesWritten = crypto.bindings.argon2_from_base64(ptr, len, encodedHash)
	preallocatedConversionBuffer:commit(numBytesWritten)

	return tostring(preallocatedConversionBuffer)
end

function crypto.fromBase64(encodedHash)
	local requiredSpace = math_ceil(#encodedHash * 3 / 4) -- Worst case (no padding bytes)

	preallocatedConversionBuffer:reset()
	local ptr, len = preallocatedConversionBuffer:reserve(requiredSpace)
	local numBytesWritten = crypto.bindings.openssl_from_base64(ptr, len, encodedHash, #encodedHash)
	preallocatedConversionBuffer:commit(numBytesWritten)

	return tostring(preallocatedConversionBuffer)
end

return crypto
