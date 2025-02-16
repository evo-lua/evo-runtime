local console = require("console")
local iconv = require("iconv")
local ffi = require("ffi")
local jit = require("jit")

local SAMPLE_SIZE = 500000

local UTF_MAX_BYTES_PER_CODEPOINT = 4
local CP949_INPUT_STRING = "\192\175\192\250\192\206\197\205\198\228\192\204\189\186"
local UTF8_OUTPUT_STRING = "유저인터페이스"
local function iconv_lowlevel(input)
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
	return result, converted
end

local function iconv_lua(input)
	local output, message = iconv.convert(input, "CP949", "UTF-8")
	return output, message
end

-- This should more or less match what iconv.convert is doing, minus validation/error handling
local readBuffer = buffer.new()
local writeBuffer = buffer.new()
local request = ffi.new("iconv_request_t")
local function iconv_cpp(input)
	readBuffer:put(input)
	local readCursor = readBuffer:ref()

	writeBuffer:reset()
	local writeCursor, writeBufferSize = writeBuffer:reserve(#input * UTF_MAX_BYTES_PER_CODEPOINT)

	request.input.charset = "CP949"
	request.input.buffer = readCursor
	request.input.length = #input
	request.input.remaining = #input

	request.output.charset = "UTF-8"
	request.output.buffer = writeCursor
	request.output.length = writeBufferSize
	request.output.remaining = writeBufferSize

	local result = iconv.bindings.iconv_convert(request)
	local numBytesWritten = tonumber(request.output.length - request.output.remaining)
	writeBuffer:commit(numBytesWritten)

	return result, tostring(writeBuffer)
end

math.randomseed(os.clock())
local availableBenchmarks = {
	function()
		local label = "[FFI] Multi-step conversions using the libiconv API directly (manual descriptor management)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			local result, output = iconv_lowlevel(CP949_INPUT_STRING)
			assert(result == ffi.C.ICONV_RESULT_OK, iconv.strerror(result))
			assert(output == UTF8_OUTPUT_STRING, output)
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[FFI] Immediate conversion using iconv.bindings.iconv_convert (manual buffer management)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			local result, output = iconv_cpp(CP949_INPUT_STRING)
			assert(result == ffi.C.ICONV_RESULT_OK, iconv.strerror(result))
			assert(output == UTF8_OUTPUT_STRING, output)
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[FFI] Immediate conversion using iconv.convert (idiomatic Lua wrapper, with preallocation)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			local output, message = iconv_lua(CP949_INPUT_STRING)
			assert(output == UTF8_OUTPUT_STRING, message)
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
