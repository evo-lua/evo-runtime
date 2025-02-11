local ffi = require("ffi")
local validation = require("validation")

local validateString = validation.validateString

local ffi_string = ffi.string
local tonumber = tonumber
local tostring = tostring

local iconv = {}

iconv.cdefs = [[
typedef void* iconv_t;
typedef enum {
	CharsetConversionSuccess,
	CharsetConversionFailure,
	InvalidConversionRequest,
	InvalidConversionDescriptor,
	ForwardedSystemError,
	ConversionDescriptorClosed,
	InvalidInputBuffer,
	InvalidOutputBuffer
} iconv_result_t;

// Alias for now, replace with enum later
typedef const char* iconv_encoding_t;

typedef struct iconv_memory_t {
	iconv_encoding_t charset;
	char* buffer;
	size_t length;
	size_t remaining;
} iconv_memory_t;

typedef struct iconv_request_t {
	iconv_memory_t input;
	iconv_memory_t output;
	iconv_t handle;
} iconv_request_t;

struct static_iconv_exports_table {
	iconv_result_t (*iconv_convert)(iconv_request_t* conversion_details);
	iconv_t (*iconv_open)(const char* input_encoding, const char* output_encoding);
	int (*iconv_close)(iconv_t conversion_descriptor);
	size_t (*iconv)(iconv_t conversion_descriptor, char** input, size_t* input_size, char** output, size_t* output_size);
	iconv_result_t (*iconv_try_close)(iconv_request_t* request);
};

]]

-- Should probably move this elsewhere?
local function ffi_strerror(errno)
	return ffi.string(ffi.C.strerror(errno))
end

function iconv.initialize()
	ffi.cdef([[
		// Should probably move this elsewhere?
		char *strerror(int errnum);
	]])

	ffi.cdef(iconv.cdefs)
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

function iconv.try_close(request)
	return iconv.bindings.iconv_try_close(request)
end

return iconv
