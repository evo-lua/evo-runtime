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
	const EVP_CIPHER *EVP_aes_256_ecb(void);
	const EVP_CIPHER *EVP_aes_256_cbc(void);
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

local ciphertextBuffer = buffer.new(1024)

local function aes_encrypt_ffi(message)
	local ctx = libcrypto.EVP_CIPHER_CTX_new()
	-- if(!(ctx = EVP_CIPHER_CTX_new()))
        -- handleErrors();

	-- /*
    --  * Initialise the encryption operation. IMPORTANT - ensure you use a key
    --  * and IV size appropriate for your cipher
    --  * In this example we are using 256 bit AES (i.e. a 256 bit key). The
    --  * IV size for *most* modes is the same as the block size. For AES this
    --  * is 128 bits
    --  */
	--  if(1 != EVP_EncryptInit_ex(ctx, EVP_aes_256_cbc(), NULL, key, iv))
	-- local method = "aes-128-ecb"
	local key = string.rep("XY", 16)
	local iv = string.rep(string.char(42), 32)
	local ret = libcrypto.EVP_EncryptInit_ex(ctx, libcrypto.EVP_aes_256_cbc(), ffi.NULL, key, iv)
	--  if ret ~= 1 then handleErrors();

    -- /*
    --  * Provide the message to be encrypted, and obtain the encrypted output.
    --  * EVP_EncryptUpdate can be called multiple times if necessary
    --  */
	local encryptedMessage = ""
	local numBytesWritten = ffi.new("int")
	local ciphertext_len = 0
	-- TODO: "Which we assume to be long enough" - unhappiness ensues
	ciphertextBuffer:reset()
	local ptr, len = ciphertextBuffer:ref()
	ret = libcrypto.EVP_EncryptUpdate(ctx, ptr, ffi.new("int[1]", len), message, #message)
	-- TBD reserve/commit?
	--  if ret ~= 1 then handleErrors();
	ciphertext_len = len
	
    -- /*
    --  * Finalise the encryption. Further ciphertext bytes may be written at
    --  * this stage.
    --  */
	 libcrypto.EVP_EncryptFinal_ex(ctx, ptr + len, ffi.new("int[1]", len))
	--  if ret ~= 1 then handleErrors();
--  ciphertext_len = ciphertext_len + numBytesWritten
	
	-- local decryptedMessage = cipher.decrypt(method, encryptedMessage, key, iv) -- TBD IV?
	-- assert(decryptedMessage == message, "Decrypted message doesn't match the original plaintext")

	libcrypto.EVP_CIPHER_CTX_free(ctx)

	-- assert(ciphertext_len == 42, ciphertext_len)
	-- return ciphertext_len
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
