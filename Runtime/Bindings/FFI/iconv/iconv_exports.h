typedef struct iconv_result_t {
	uint8_t status_code;
	size_t num_bytes_written;
	const char* message;
} iconv_result_t;

struct static_iconv_exports_table {
	iconv_result_t (*iconv_convert)(char* input, size_t input_size, const char* input_encoding, const char* output_encoding, char* output, size_t output_size);
	iconv_t (*iconv_open)(const char* input_encoding, const char* output_encoding);
	int (*iconv_close)(iconv_t conversion_descriptor);
	size_t (*iconv)(iconv_t conversion_descriptor, char** input, size_t* input_size, char** output, size_t* output_size);
};