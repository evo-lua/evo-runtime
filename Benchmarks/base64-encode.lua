local console = require("console")
local crypto = require("crypto")
local openssl = require("openssl")

local tinsert = table.insert

local SAMPLE_SIZE = 10000

printf("Generating %d randomized samples of varying lengths", SAMPLE_SIZE)
console.startTimer("Generate random samples")

local inputs = {}

for i = 1, SAMPLE_SIZE, 1 do
	tinsert(inputs, openssl.random(4))
	tinsert(inputs, openssl.random(8))
	tinsert(inputs, openssl.random(16))
	tinsert(inputs, openssl.random(32))
	tinsert(inputs, openssl.random(64))
	tinsert(inputs, openssl.random(128))
	tinsert(inputs, openssl.random(256))
	tinsert(inputs, openssl.random(512))
	tinsert(inputs, openssl.random(1250))
	tinsert(inputs, openssl.random(2500))
	tinsert(inputs, openssl.random(5000))
	tinsert(inputs, openssl.random(10000))
	tinsert(inputs, openssl.random(100000))
end

console.stopTimer("Generate random samples")

math.randomseed(os.clock())
local availableBenchmarks = {
	function()
		console.startTimer("[Base64] Encoding with LuaOpenSSL")
		for i = 1, SAMPLE_SIZE, 1 do
			openssl.base64(inputs[i])
		end
		console.stopTimer("[Base64] Encoding with LuaOpenSSL")
	end,

	function()
		console.startTimer("[Base64] Encoding with FFI bindings to OpenSSL")
		for i = 1, SAMPLE_SIZE, 1 do
			crypto.toBase64(inputs[i])
		end
		console.stopTimer("[Base64] Encoding with FFI bindings to OpenSSL")
	end,

	function()
		console.startTimer("[Base64] Encoding with FFI bindings to Argon2")
		for i = 1, SAMPLE_SIZE, 1 do
			crypto.toCompactBase64(inputs[i])
		end
		console.stopTimer("[Base64] Encoding with FFI bindings to Argon2")
	end,
}

table.shuffle(availableBenchmarks)

for _, benchmark in ipairs(availableBenchmarks) do
	benchmark()
end
