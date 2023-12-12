local ffi = require("ffi")
local validation = require("validation")

local validateString = validation.validateString

local tonumber = tonumber
local tostring = tostring

local iconv = {}

iconv.cdefs = [[
	struct static_iconv_exports_table {
		size_t (*iconv_convert)(char* input, size_t input_size, const char* input_encoding, const char* output_encoding, char* output, size_t output_size);
	};
]]

function iconv.initialize()
	ffi.cdef(iconv.cdefs)
end

local UTF_BYTES_PER_CODEPOINT = 4

function iconv.convert(input, inputEncoding, outputEncoding)
	validateString(input, "input")
	validateString(inputEncoding, "inputEncoding")
	validateString(outputEncoding, "outputEncoding")

	if #input == 0 then
		-- Prevents LuaJIT from trying to collect a NULL buffer (= crash)
		return "", 0
	end

	local inputBuffer = ffi.new("char[?]", #input, input) -- Wasteful, but iconv modifies the input buffer
	local maxOutputBufferSize = #input * UTF_BYTES_PER_CODEPOINT -- Worst case scenario (also wasteful)
	local outputBuffer = buffer.new(maxOutputBufferSize)
	local ptr, len = outputBuffer:reserve(maxOutputBufferSize)

	local numBytesWritten =
		iconv.bindings.iconv_convert(inputBuffer, ffi.sizeof(inputBuffer), inputEncoding, outputEncoding, ptr, len)
	outputBuffer:commit(numBytesWritten)

	return tostring(outputBuffer), tonumber(numBytesWritten)
end

return iconv
