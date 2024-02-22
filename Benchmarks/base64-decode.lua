local console = require("console")
local crypto = require("crypto")
local openssl = require("openssl")

local tinsert = table.insert

local SAMPLE_SIZE = 5000

printf("Generating %d randomized samples of varying lengths", SAMPLE_SIZE)
console.startTimer("Generate random samples")

local inputs = {
	luaopenssl = {},
	openssl = {},
	argon2 = {},
}

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

for i, randomBytes in ipairs(inputs) do
	inputs.luaopenssl[i] = openssl.base64(randomBytes)
	inputs.openssl[i] = crypto.toBase64(randomBytes)
	inputs.argon2[i] = crypto.toCompactBase64(randomBytes)
end

console.stopTimer("Generate random samples")

math.randomseed(os.clock())
local availableBenchmarks = {
	function()
		console.startTimer("[Base64] Decoding with LuaOpenSSL")
		for i = 1, SAMPLE_SIZE, 1 do
			openssl.base64(inputs.luaopenssl[i], false)
		end
		console.stopTimer("[Base64] Decoding with LuaOpenSSL")
	end,

	function()
		console.startTimer("[Base64] Decoding with FFI bindings to OpenSSL")
		for i = 1, SAMPLE_SIZE, 1 do
			crypto.fromBase64(inputs.openssl[i])
		end
		console.stopTimer("[Base64] Decoding with FFI bindings to OpenSSL")
	end,

	function()
		console.startTimer("[Base64] Decoding with FFI bindings to Argon2")
		for i = 1, SAMPLE_SIZE, 1 do
			crypto.fromCompactBase64(inputs.argon2[i])
		end
		console.stopTimer("[Base64] Decoding with FFI bindings to Argon2")
	end,
}

table.shuffle(availableBenchmarks)

for _, benchmark in ipairs(availableBenchmarks) do
	benchmark()
end
