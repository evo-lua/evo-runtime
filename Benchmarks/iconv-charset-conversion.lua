local console = require("console")
local iconv = require("iconv")
local ffi = require("ffi")

local SAMPLE_SIZE = 500000

local function iconv_lowlevel()
	local input = "\192\175\192\250\192\206\197\205\198\228\192\204\189\186"
	local descriptor = iconv.bindings.iconv_open("UTF-8", "CP949")

	local inputSize = ffi.new("size_t[1]", #input)
	local inputBuffer = ffi.new("char[?]", #input, input)
	local inputRef = ffi.new("char*[1]", inputBuffer)

	local worstCaseOutputSize = #input * 4
	local outputSize = ffi.new("size_t[1]", worstCaseOutputSize)
	local outputBuffer = ffi.new("char[256]")
	local outputRef = ffi.new("char*[1]", outputBuffer)

	local result = iconv.bindings.iconv(descriptor, inputRef, inputSize, outputRef, outputSize)
	local numConversionsPerformed = worstCaseOutputSize - outputSize[0]
	local converted = ffi.string(outputBuffer, numConversionsPerformed)

	iconv.bindings.iconv_close(descriptor)
	return converted, result
end

local function iconv_lua()
	local input = "\192\175\192\250\192\206\197\205\198\228\192\204\189\186"
	local output, message = iconv.convert(input, "CP949", "UTF-8")
	return output, message
end

local function iconv_cpp()
	local inputBuffer = buffer.new()
	local outputBuffer = buffer.new(1024)
	local ptr, len = outputBuffer:reserve(1024)
	local result = iconv.bindings.iconv_convert(inputBuffer, #inputBuffer, "CP949", "UTF-8", ptr, len)
	return result
end

math.randomseed(os.clock())
local availableBenchmarks = {
	function()
		local label = "[FFI] Low-level API (tedious and slow, but the most flexible)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			iconv_lowlevel()
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[FFI] One-shot C++ conversion (fast but less flexible)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			iconv_cpp()
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[FFI] Lua-friendly wrapper (safer, but slower)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			iconv_lua()
		end
		console.stopTimer(label)
	end,
}

table.shuffle(availableBenchmarks)
jit.off()
print("Running benchmarks with JIT=OFF")
for _, benchmark in ipairs(availableBenchmarks) do
	benchmark()
end

table.shuffle(availableBenchmarks)
print("Running benchmarks with JIT=ON")
jit.on()
for _, benchmark in ipairs(availableBenchmarks) do
	benchmark()
end
