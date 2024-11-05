local console = require("console")
local openssl = require("openssl")
local cipher = openssl.cipher

local SAMPLE_SIZE = 100000

local function aes_encrypt_lua(message)
	local method = "aes-128-ecb"
	local key = string.rep("XY", 16)
	local iv = string.rep(string.char(42), 32)
	local encryptedMessage = cipher.encrypt(method, message, key, iv)
	local decryptedMessage = cipher.decrypt(method, encryptedMessage, key, iv) -- TBD IV?
	assert(decryptedMessage == message, "Decrypted message doesn't match the original plaintext")
end

local ffi = require("ffi")
local libcrypto = ffi.load("crypto")
ffi.cdef([[
	// TBD
	// EVP_MAX_KEY_LENGTH = 64
	// EVP_MAX_IV_LENGTH = 16
	// OPENSSL_malloc
	// OPENSSL_free

	// libcrypto types
	typedef void* EVP_CIPHER_CTX;
	typedef void* EVP_CIPHER;
	typedef void* ENGINE;

	// libcrypto APIs
	EVP_CIPHER_CTX *EVP_CIPHER_CTX_new(void);
	const EVP_CIPHER *EVP_get_cipherbyname(const char *name);
	int EVP_EncryptInit_ex(EVP_CIPHER_CTX *ctx,
                                  const EVP_CIPHER *cipher, ENGINE *impl,
                                  const unsigned char *key,
                                  const unsigned char *iv);
	int EVP_CIPHER_CTX_set_padding(EVP_CIPHER_CTX *c, int pad);
	int EVP_CIPHER_CTX_get_block_size(const EVP_CIPHER_CTX *ctx);
	int EVP_EncryptUpdate(EVP_CIPHER_CTX *ctx, unsigned char *out,
                                 int *outl, const unsigned char *in, int inl);
	int EVP_EncryptFinal_ex(EVP_CIPHER_CTX *ctx, unsigned char *out,
                                   int *outl);
	void EVP_CIPHER_CTX_free(EVP_CIPHER_CTX *c);
]])
print(libcrypto)

local function aes_encrypt_ffi(plainText)

end

-- TODO decrypt/assert result matches input? Might be out of scope here...

math.randomseed(os.clock())
local availableBenchmarks = {
	function()
		local label = "[Lua] AES-Encrypt via lua-openssl"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			aes_encrypt_lua("Hello world!")
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[FFI] AES-Encrypt via openssl"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			aes_encrypt_ffi("TBD")
		end
		console.stopTimer(label)
	end,
}

table.shuffle(availableBenchmarks)

for _, benchmark in ipairs(availableBenchmarks) do
	benchmark()
end
