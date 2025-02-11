typedef enum {
	CharsetConversionSuccess,
	CharsetConversionFailure,
	InvalidConversionRequest,
	InvalidConversionDescriptor,
	ForwardedSystemError,
	ConversionDescriptorClosed,
} iconv_result_t;

typedef struct iconv_progress_t {
	char* buffer;
	size_t length;
	size_t remaining;
	const char* encoding;
} iconv_progress_t;

typedef struct iconv_request_t {
	iconv_progress_t input;
	iconv_progress_t output;
	iconv_t handle;
} iconv_request_t;

struct static_iconv_exports_table {
	iconv_result_t (*iconv_convert)(iconv_request_t* conversion_details);
	iconv_t (*iconv_open)(const char* input_encoding, const char* output_encoding);
	int (*iconv_close)(iconv_t conversion_descriptor);
	size_t (*iconv)(iconv_t conversion_descriptor, char** input, size_t* input_size, char** output, size_t* output_size);
	int (*iconv_try_close)(iconv_request_t* request);
};