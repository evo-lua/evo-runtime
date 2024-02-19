local buffer = require("string.buffer")
local ffi = require("ffi")

local ffi_new = ffi.new
local ffi_string = ffi.string
local math_ceil = math.ceil
local tostring = tostring
local math_floor = math.floor
local math_min = math.min

local crypto = {
	-- Should match parameters for EVP_KDF_fetch (OpenSSL)
	KDF_ARGON2D = "ARGON2D",
	KDF_ARGON2I = "ARGON2I",
	KDF_ARGON2ID = "ARGON2ID",
}

crypto.cdefs = [[

typedef struct kdf_parameters_t {
	const char* kdf;
	uint32_t version;
	uint32_t kilobytes;
	uint32_t threads;
	uint32_t lanes;
	size_t size;
	uint32_t iterations;
} kdf_parameters_t;

typedef struct kdf_input_t {
	const char* password;
	size_t pw_length;
	const char* salt;
	size_t salt_length;
} kdf_input_t;

typedef struct kdf_result_t {
	bool success;
	unsigned char* hash;
	char* message;
} kdf_result_t;

struct static_crypto_exports_table {
	// OpenSSL (libcrypto) metadata
	const char* (*version_text)(void);
	long int (*version_number)(void);

	// Argon2 MCF utilities
	size_t (*openssl_to_base64)(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len);
	size_t (*openssl_from_base64)(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len);
	size_t (*argon2_to_base64)(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len);
	size_t (*argon2_from_base64)(unsigned char* dst, size_t dst_len, const char* src);
	void (*openssl_kdf_derive)(kdf_input_t inputs, kdf_parameters_t parameters, kdf_result_t* result);

	int (*openssl_crypto_memcmp)(const void* a, const void* b, size_t len);
};

]]

-- As per https://www.openssl.org/docs/manmaster/man3/ERR_error_string_n.html
local OPENSSL_MIN_ERROR_STRING_LENGTH = 120
local preallocatedMessageExchangeBuffer = buffer:new(OPENSSL_MIN_ERROR_STRING_LENGTH)
local preallocatedConversionBuffer = buffer.new(128)

function crypto.initialize()
	ffi.cdef(crypto.cdefs)

	-- Based on https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html#argon2id
	crypto.DEFAULT_KDF_PARAMETERS = {
		kdf = crypto.KDF_ARGON2ID,
		version = 0x13,
		kilobytes = 47104,
		threads = 1,
		lanes = 1,
		size = 32,
		iterations = 3,
	}
end

function crypto.version()
	local versionText = ffi.string(crypto.bindings.version_text())
	local incrementalVersionNumber = tonumber(crypto.bindings.version_number())
	return versionText, incrementalVersionNumber
end

function crypto.mcf(hash, salt, parameters)
	parameters = parameters or crypto.DEFAULT_KDF_PARAMETERS
	local mcf = string.format(
		"$%s$v=%d$m=%d,t=%d,p=%d$%s$%s",
		string.lower(parameters.kdf),
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

function crypto.hash(plaintextPassword, salt, kdfParameters)
	kdfParameters = kdfParameters or crypto.DEFAULT_KDF_PARAMETERS

	local parameters = ffi_new("kdf_parameters_t")
	parameters.kdf = kdfParameters.kdf or crypto.DEFAULT_KDF_PARAMETERS.kdf
	parameters.version = kdfParameters.version or crypto.DEFAULT_KDF_PARAMETERS.version
	parameters.kilobytes = kdfParameters.kilobytes or crypto.DEFAULT_KDF_PARAMETERS.kilobytes
	parameters.threads = kdfParameters.threads or crypto.DEFAULT_KDF_PARAMETERS.threads
	parameters.lanes = kdfParameters.lanes or crypto.DEFAULT_KDF_PARAMETERS.lanes
	parameters.size = kdfParameters.size or crypto.DEFAULT_KDF_PARAMETERS.size
	parameters.iterations = kdfParameters.iterations or crypto.DEFAULT_KDF_PARAMETERS.iterations

	local inputs = ffi_new("kdf_input_t")
	inputs.password = plaintextPassword
	inputs.pw_length = #plaintextPassword
	inputs.salt = salt
	inputs.salt_length = #salt

	preallocatedConversionBuffer:reset()
	preallocatedMessageExchangeBuffer:reset()
	local result = ffi_new("kdf_result_t")
	result.hash = preallocatedConversionBuffer:reserve(parameters.size) -- No need to pass the length since we set it in advance
	result.message = preallocatedMessageExchangeBuffer:reserve(OPENSSL_MIN_ERROR_STRING_LENGTH) -- Ditto
	crypto.bindings.openssl_kdf_derive(inputs, parameters, result)
	preallocatedConversionBuffer:commit(parameters.size)
	preallocatedMessageExchangeBuffer:commit(OPENSSL_MIN_ERROR_STRING_LENGTH)

	if not result.success then
		return nil, "OpenSSL " .. ffi_string(preallocatedMessageExchangeBuffer)
	end

	return tostring(preallocatedConversionBuffer)
end

function crypto.verify(plaintextPassword, salt, hash, kdfParameters)
	local rehash = crypto.hash(plaintextPassword, salt, kdfParameters)
	local diff = crypto.bindings.openssl_crypto_memcmp(hash, rehash, math_min(#hash, #rehash))
	print(diff, tonumber(diff), hash, rehash)
	return tonumber(diff) == 0
end

return crypto
