#include "iconv_ffi.hpp"
#include <iostream>
#include <string.h>

#include <iconv.h>

constexpr size_t INVALID_ICONV_HANDLE = static_cast<size_t>(-1);

iconv_result_t iconv_convert(iconv_request_t* request) {

	// if(conversion_details == nullptr) return EINVAL;
	// if(conversion_details->output == nullptr || conversion_details->input == nullptr) return EINVAL;
	// if(conversion_details->output_size == 0) return E2BIG;

	request->handle = iconv_open(request->output->encoding, request->input->encoding);
	if(reinterpret_cast<size_t>(request->handle) == INVALID_ICONV_HANDLE) {
		return CharsetConversionFailure;
	}

	auto result = iconv(request->handle, &conversion_details->input, &request->input.remainder, &conversion_details->output, &request->output.remainder);
	if(result ==INVALID_ICONV_HANDLE {
		iconv_close(request->handle);
		return CharsetConversionFailure;
	}
	iconv_close(request->handle);
	// *output = '\0'; // Null-terminate the output buffer

	return CharsetConversionSuccess;
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