#include "iconv_ffi.hpp"
#include "macros.hpp"

#include <iostream>
#include <string>

#include <iconv.h>

iconv_result_t iconv_convert(char* input, size_t input_length, const char* input_encoding, const char* output_encoding, char* output, size_t output_size) {

	iconv_result_t result {
		.status_code = EINVAL,
		.num_bytes_written = 0,
		.message = strerror(EINVAL),
	};

	if(output == nullptr || input == nullptr) return result;
	if(output_size == 0) return result;

	size_t num_input_bytes_left = input_length;

	iconv_t conversion_descriptor = iconv_open(output_encoding, input_encoding);
	if(conversion_descriptor == (iconv_t)-1) {
		result.message = strerror(errno);
		result.status_code = errno;
		result.num_bytes_written = 0;
		return result;
	}

	size_t num_output_bytes_left = output_size;
	if(iconv(conversion_descriptor, &input, &num_input_bytes_left, &output, &num_output_bytes_left) == (size_t)-1) {
		iconv_close(conversion_descriptor);
		result.message = strerror(errno);
		result.status_code = errno;
		result.num_bytes_written = output_size - num_output_bytes_left;
		return result;
	}
	iconv_close(conversion_descriptor);
	*output = '\0'; // Null-terminate the output buffer

	const size_t num_processed_bytes = output_size - num_output_bytes_left;

	result.message = strerror(0);
	result.status_code = 0;
	result.num_bytes_written = num_processed_bytes;

	return result;
}

namespace iconv_ffi {

#include "iconv_exports_generated.h"

	std::string getTypeDefinitions() {
		return std::string(*Runtime_Bindings_iconv_exports_h, Runtime_Bindings_iconv_exports_h_len);
	}

	void* getExportsTable() {
		static struct static_iconv_exports_table exports_table;

		exports_table.iconv_convert = &iconv_convert;

		return &exports_table;
	}

}