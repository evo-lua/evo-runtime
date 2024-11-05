local console = require("console")
local cipher = require('openssl').cipher

local SAMPLE_SIZE = 100000

local function aes_encrypt_lua(message)
	local method = "aes-128-ecb"
	local key = string.rep("XY", 16)
	local iv = string.rep(string.char(42), 32)
	local encryptedMessage = cipher.encrypt(method, message, key, iv)
	local decryptedMessage = cipher.decrypt(method, encryptedMessage, key, iv) -- TBD IV?
	assert(decryptedMessage == message, "Decrypted message doesn't match the original plaintext")
end

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
