local bit = require("bit")
local console = require("console")

local SAMPLE_SIZE = 100

local function aes_encrypt_lua(plainText)

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
			aes_encrypt_lua("TBD")
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
