#include "iconv_ffi.hpp"
#include <iostream>
#include <string.h>

#include <iconv.h>

size_t iconv_convert(char* input, const char* input_encoding, const char* output_encoding, char* output, size_t output_size) {
	if(output == nullptr || input == nullptr) return 0;
	if(output_size == 0) return 0;

	size_t num_input_bytes_left = strlen(input);

	iconv_t conversion_descriptor = iconv_open(output_encoding, input_encoding);
	if(conversion_descriptor == (iconv_t)-1) {
		std::cout << "WARNING: iconv_open failed with error code " << errno << " (" << strerror(errno) << ")" << std::endl;
		std::cout << "Input: " << input << std::endl;
		std::cout << "Input Encoding: " << input_encoding << std::endl;
		std::cout << "Output Encoding: " << output_encoding << std::endl;
		return 0;
	}

	size_t num_output_bytes_left = output_size;
	if(iconv(conversion_descriptor, &input, &num_input_bytes_left, &output, &num_output_bytes_left) == (size_t)-1) {
		std::cout << "WARNING: iconv_open failed with error code " << errno << " (" << strerror(errno) << ")" << std::endl;
		std::cout << "Input: " << input << std::endl;
		std::cout << "Input Encoding: " << input_encoding << std::endl;
		std::cout << "Output Encoding: " << output_encoding << std::endl;
		return 0;
	}
	iconv_close(conversion_descriptor);
	*output = '\0'; // Null-terminate the output buffer

	const size_t num_processed_bytes = output_size - num_output_bytes_left;
	return num_processed_bytes;
}

namespace iconv_ffi {

	void* getExportsTable() {
		static struct static_iconv_exports_table exports_table;

		exports_table.iconv_convert = &iconv_convert;

		return &exports_table;
	}

}