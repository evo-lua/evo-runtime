local ffi = require("ffi")
local validation = require("validation")

local validateString = validation.validateString

local tonumber = tonumber
local tostring = tostring

local UTF_MAX_BYTES_PER_CODEPOINT = 4

local iconv = {}

iconv.cdefs = [[
typedef void* iconv_t;
typedef enum iconv_result_t {
	ICONV_RESULT_OK,
	ICONV_INVALID_REQUEST,
	ICONV_INVALID_DESCRIPTOR,
	ICONV_INVALID_INPUT,
	ICONV_INVALID_OUTPUT,
	ICONV_CONVERSION_FAILED,
	ICONV_INCOMPLETE_INPUT,
	ICONV_WRITEBUFFER_FULL,
	ICONV_RESULT_LAST,
} iconv_result_t;

typedef char* iconv_cursor_t;
typedef const char* iconv_encoding_t; // Aliased for now, replace with enum later

typedef struct iconv_memory_t {
	iconv_encoding_t charset;
	iconv_cursor_t buffer;
	size_t length;
	size_t remaining;
} iconv_memory_t;

typedef struct iconv_request_t {
	iconv_memory_t input;
	iconv_memory_t output;
	iconv_t handle;
} iconv_request_t;

struct static_iconv_exports_table {

	// Exports from iconv.h
	iconv_t (*iconv_open)(const char* input_encoding, const char* output_encoding);
	int (*iconv_close)(iconv_t conversion_descriptor);
	size_t (*iconv)(iconv_t conversion_descriptor, char** input, size_t* input_size, char** output, size_t* output_size);

	// Charset conversion API
	iconv_result_t (*iconv_convert)(iconv_request_t* conversion_details);
	iconv_result_t (*iconv_try_close)(iconv_request_t* request);

	// Utility methods
	const char* (*iconv_strerror)(iconv_result_t status);
	bool (*iconv_check_result)(iconv_t handle);
};

]]

function iconv.initialize()
	ffi.cdef(iconv.cdefs)
end

local request, readBuffer, writeBuffer
function iconv.convert(input, inputEncoding, outputEncoding)
	validateString(input, "input")
	validateString(inputEncoding, "inputEncoding")
	validateString(outputEncoding, "outputEncoding")

	-- Preallocate resources only when needed; it's somewhat costly otherwise
	request = request or ffi.new("iconv_request_t")
	readBuffer = readBuffer or buffer.new(256)
	writeBuffer = writeBuffer or buffer.new(256)

	readBuffer:put(input)
	local readCursor = readBuffer:ref()
	request.input.charset = "CP949"
	request.input.buffer = readCursor
	request.input.length = #input
	request.input.remaining = #input

	-- If the input is empty, reserving a zero-length write buffer may lead to misleading errors
	local maxRequiredWriteBufferSize = math.max(1, #input * UTF_MAX_BYTES_PER_CODEPOINT)

	writeBuffer:reset()
	local writeCursor, writeBufferCapacity = writeBuffer:reserve(maxRequiredWriteBufferSize)
	request.output.charset = "UTF-8"
	request.output.buffer = writeCursor
	request.output.length = writeBufferCapacity
	request.output.remaining = writeBufferCapacity

	local result = iconv.bindings.iconv_convert(request)
	local numBytesWritten = tonumber(request.output.length - request.output.remaining)
	writeBuffer:commit(numBytesWritten)

	if result ~= ffi.C.ICONV_RESULT_OK then
		return nil, iconv.strerror(result)
	end

	return tostring(writeBuffer), iconv.strerror(result)
end

function iconv.strerror(result)
	return ffi.string(iconv.bindings.iconv_strerror(result))
end

return iconv
