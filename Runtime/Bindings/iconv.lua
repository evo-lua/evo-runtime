local bindings = require("bindings")
local ffi = require("ffi")
local validation = require("validation")

local validateString = validation.validateString

local ffi_string = ffi.string
local tonumber = tonumber
local tostring = tostring

local iconv = {}

-- Should probably move this elsewhere?
local function ffi_strerror(errno)
	return ffi.string(ffi.C.strerror(errno))
end

function iconv.initialize()
	ffi.cdef([[
		// Should probably move this elsewhere?
		char *strerror(int errnum);
	]])

	ffi.cdef(bindings.iconv.cdefs)
end

local UTF_BYTES_PER_CODEPOINT = 4

function iconv.convert(input, inputEncoding, outputEncoding)
	validateString(input, "input")
	validateString(inputEncoding, "inputEncoding")
	validateString(outputEncoding, "outputEncoding")

	if #input == 0 then
		-- Prevents LuaJIT from trying to collect a NULL buffer (= crash)
		return nil, ffi_strerror(22) -- EINVAL
	end

	local inputBuffer = ffi.new("char[?]", #input + 1, input) -- Wasteful, but iconv modifies the input buffer
	local maxOutputBufferSize = #input * UTF_BYTES_PER_CODEPOINT -- Worst case scenario (also wasteful)
	local outputBuffer = buffer.new(maxOutputBufferSize)
	local ptr, len = outputBuffer:reserve(maxOutputBufferSize)

	local result = iconv.bindings.iconv_convert(inputBuffer, #input, inputEncoding, outputEncoding, ptr, len)

	local numBytesWritten = tonumber(result.num_bytes_written)
	outputBuffer:commit(numBytesWritten)

	if tonumber(result.status_code) ~= 0 then
		local errorMessage = ffi_string(result.message)
		return nil, errorMessage
	end

	return tostring(outputBuffer), ffi_strerror(0)
end

return iconv
