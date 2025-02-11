#include "iconv_ffi.hpp"
#include <iostream>
#include <string.h>

#include <iconv.h>

constexpr size_t INVALID_ICONV_HANDLE = static_cast<size_t>(-1);

iconv_result_t iconv_convert(char* input, size_t input_length, const char* input_encoding, const char* output_encoding, char* output, size_t output_size) {

	if(output == nullptr || input == nullptr) return result;
	if(output_size == 0) return result;

	size_t num_input_bytes_left = input_length; // TODO store in namespace?

	iconv_t conversion_descriptor = iconv_open(output_encoding, input_encoding);
	if(reinterpret_cast<size_t>(conversion_descriptor) == INVALID_ICONV_HANDLE) {
		return CharsetConversionFailure;
	}

	size_t num_output_bytes_left = output_size;
	if(iconv(conversion_descriptor, &input, &num_input_bytes_left, &output, &num_output_bytes_left) == (size_t)-1) {
		iconv_close(conversion_descriptor);
		// Discard changes since the conversion probably needs to be restarted anyway
		return CharsetConversionFailure;
	}
	iconv_close(conversion_descriptor);
	*output = '\0'; // Null-terminate the output buffer

	const size_t num_processed_bytes = output_size - num_output_bytes_left;

	// result.message = strerror(0);
	result.status_code = 0;
	result.num_bytes_written = num_processed_bytes;

	return result;
}

namespace iconv_ffi {

	void* getExportsTable() {
		static struct static_iconv_exports_table exports = {
			.iconv_convert = &iconv_convert,
			.iconv_open = &iconv_open,
			.iconv_close = &iconv_close,
			.iconv = &iconv,

			// Shared constants
			.CHARSET_CONVERSION_FAILED = CHARSET_CONVERSION_FAILED,
		};

		return &exports;
	}

}