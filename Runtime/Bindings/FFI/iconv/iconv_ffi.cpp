#include "iconv_ffi.hpp"
#include <iostream>
#include <string.h>

#include <iconv.h>

constexpr size_t INVALID_ICONV_HANDLE = static_cast<size_t>(-1);

iconv_result_t iconv_try_close(iconv_request_t* request) {
	if(request == nullptr) return InvalidConversionRequest;
	if(request->handle == nullptr) return InvalidConversionDescriptor;

	// MINGW64's iconv implementation can't handle closing invalid descriptors
	if(request == INVALID_ICONV_HANDLE) return InvalidConversionDescriptor;

	int result = iconv_close(request->handle);
	if(result != 0) return ForwardedSystemError;

	return ConversionDescriptorClosed;
}

iconv_result_t iconv_convert(iconv_request_t* request) {

	// if(conversion_details == nullptr) return EINVAL;
	// if(conversion_details->output == nullptr || conversion_details->input == nullptr) return EINVAL;
	// if(conversion_details->output_size == 0) return E2BIG;

	request->handle = iconv_open(request->output.encoding, request->input.encoding);
	if(reinterpret_cast<size_t>(request->handle) == INVALID_ICONV_HANDLE) {
		return CharsetConversionFailure;
	}

	auto result = iconv(request->handle, &request->input.buffer, &request->input.remaining, &request->output.buffer, &request->output.remaining);
	if(result == INVALID_ICONV_HANDLE) {
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
			.iconv_try_close = &iconv_try_close,
		};

		return &exports;
	}

}