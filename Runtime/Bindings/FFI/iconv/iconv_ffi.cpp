#include "iconv_ffi.hpp"
#include <iostream>
// #include <limits>
#include <stdint.h>
#include <string.h>

#include <iconv.h>

// constexpr size_t INVALID_POINTER_ADDRESS = SIZE_MAX;
constexpr size_t INVALID_CONVERSION_HANDLE = SIZE_MAX;
// constexpr iconv_t INVALID_CONVERSION_HANDLE = static_cast<iconv_t>(SIZE_MAX);
// constexpr iconv_t INVALID_CONVERSION_HANDLE = reinterpret_cast<iconv_t>(-1);
// constexpr iconv_t INVALID_CONVERSION_HANDLE = reinterpret_cast<iconv_t>(static_cast<uintptr_t>(-1));
// constexpr iconv_t INVALID_CONVERSION_HANDLE = reinterpret_cast<iconv_t>(-1LL);

inline bool sanity_check_descriptor(const iconv_t& handle) {
	return reinterpret_cast<size_t>(handle) != INVALID_CONVERSION_HANDLE;
}

inline bool sanity_check_buffer(const iconv_memory_t& workload) {
	if(workload.buffer == nullptr) return false;
	if(workload.length == 0 || workload.remaining == 0) return false;
	if(workload.remaining > workload.length) return false;

	return true;
}

iconv_result_t iconv_try_close(iconv_request_t* request) {
	if(request == nullptr) return InvalidConversionRequest;
	if(request->handle == nullptr) return InvalidConversionDescriptor;

	// MINGW64's iconv implementation can't handle closing invalid descriptors
	if(!sanity_check_descriptor(request->handle)) {
		return InvalidConversionDescriptor;
	}

	int result = iconv_close(request->handle);
	if(result != 0) return ForwardedSystemError;

	return ConversionDescriptorClosed;
}

iconv_result_t iconv_convert(iconv_request_t* request) {

	if(request == nullptr) return InvalidConversionRequest;

	if(!sanity_check_buffer(request->input)) {
		return InvalidInputBuffer;
	};

	if(!sanity_check_buffer(request->output)) {
		return InvalidOutputBuffer;
	};

	request->handle = iconv_open(request->input.charset, request->output.charset);
	if(!sanity_check_descriptor(request->handle)) {
		return CharsetConversionFailure;
	}

	iconv(request->handle, &request->input.buffer, &request->input.remaining, &request->output.buffer, &request->output.remaining);
	if(!sanity_check_descriptor(request->handle)) {
		iconv_try_close(request);
		return InvalidConversionDescriptor;
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