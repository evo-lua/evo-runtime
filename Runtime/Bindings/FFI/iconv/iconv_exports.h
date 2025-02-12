typedef enum iconv_result_t {
	ICONV_RESULT_OK,
	CharsetConversionSuccess, // ICONV_CONVERSION_SUCCEEDED
	CharsetConversionFailure, // ICONV_CONVERSION_FAILED
	InvalidConversionRequest, // ICONV_INVALID_REQUEST
	InvalidConversionDescriptor, // ICONV_INVALID_DESCRIPTOR
	ForwardedSystemError, // ICONV_CHECK_ERRNO
	ConversionDescriptorClosed, // ICONV_DESCRIPTOR_CLOSED
	InvalidInputBuffer, // ICONV_INVALID_INPUT
	InvalidOutputBuffer, // ICONV_INVALID_OUTPUT
	ICONV_CHECK_ERRNO,
	ICONV_RESULT_LAST, /
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
	const char* (*iconv_strerror)(iconv_result_t status);
};