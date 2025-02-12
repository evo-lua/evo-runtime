#include "iconv_ffi.hpp"
#include <iostream>
#include <stdint.h>
#include <string.h>

#include <iconv.h>

inline bool sanity_check_descriptor(const iconv_t& handle) {
	constexpr size_t INVALID_CONVERSION_HANDLE = SIZE_MAX;
	return reinterpret_cast<size_t>(handle) != INVALID_CONVERSION_HANDLE;
}

inline bool sanity_check_buffer(const iconv_memory_t& workload) {
	if(workload.buffer == nullptr) return false;
	if(workload.length == 0 || workload.remaining == 0) return false;
	if(workload.remaining > workload.length) return false;

	return true;
}

iconv_result_t iconv_try_close(iconv_request_t* request) {
	if(request == nullptr) return ICONV_INVALID_REQUEST;
	if(request->handle == nullptr) return ICONV_INVALID_HANDLE;

	// MINGW64's iconv implementation can't handle closing invalid descriptors
	if(!sanity_check_descriptor(request->handle)) {
		return ICONV_INVALID_HANDLE;
	}

	int result = iconv_close(request->handle);
	if(result != 0) return ICONV_CHECK_ERRNO;

	return ICONV_RESULT_OK;
}

iconv_result_t iconv_convert(iconv_request_t* request) {

	if(request == nullptr) return ICONV_INVALID_REQUEST;

	if(!sanity_check_buffer(request->input)) {
		return ICONV_INVALID_INPUT;
	};

	if(!sanity_check_buffer(request->output)) {
		return ICONV_INVALID_OUTPUT;
	};

	request->handle = iconv_open(request->input.charset, request->output.charset);
	if(!sanity_check_descriptor(request->handle)) {
		return ICONV_INVALID_HANDLE;
	}

	iconv(request->handle, &request->input.buffer, &request->input.remaining, &request->output.buffer, &request->output.remaining);
	if(!sanity_check_descriptor(request->handle)) {
		// The handle was valid before, so the request couldn't be completed (caller should retry)
		iconv_try_close(request);
		return ICONV_CHECK_ERRNO;
	}
	iconv_close(request->handle);
	// *output = '\0'; // Null-terminate the output buffer

	return ICONV_RESULT_OK;
}

// #include <string>
// #include <unordered_map>

// constexpr std::unordered_map<iconv_result_t, const char*> iconv_error_strings = {
// 	{ ICONV_RESULT_OK, "Success: Not an error" },
// 	{ ICONV_INVALID_REQUEST, "Failed: Invalid conversion request" },
// 	{ ICONV_INVALID_HANDLE, "Failed: Not a valid conversion descriptor" },
// 	{ ICONV_CONVERSION_FAILED, "Failed: Charset conversion failed" },
// 	{ ICONV_INVALID_INPUT, "Failed: The provided input buffer is invalid, incomplete, or has been corrupted" },
// 	{ ICONV_INVALID_OUTPUT, "Failed: The provided output buffer is invalid, incomplete, or has been corrupted" },
// 	{ ICONV_CHECK_ERRNO, "Failed: Use errno and strerror to retrieve the last system-level error" },
// 	{ ICONV_RESULT_LAST, "Unknown or invalid result: This should never happen" },
// };

#include <array>

constexpr std::array<const char*, ICONV_RESULT_LAST + 1> iconv_error_strings { {
	"Success: Not an error", // ICONV_RESULT_OK
	"Failed: Invalid conversion request", // ICONV_INVALID_REQUEST
	"Failed: Not a valid conversion descriptor", // ICONV_INVALID_HANDLE
	"Failed: Charset conversion failed", // ICONV_CONVERSION_FAILED
	"Failed: The provided input buffer is invalid, incomplete, or has been corrupted", // ICONV_INVALID_INPUT
	"Failed: The provided output buffer is invalid, incomplete, or has been corrupted", // ICONV_INVALID_OUTPUT
	"Failed: Use errno and strerror to retrieve the last system-level error", // ICONV_CHECK_ERRNO
	"Unknown or invalid result: This should never happen" // ICONV_RESULT_LAST
} };

const char* iconv_strerror(iconv_result_t status) {
	status = std::min(status, ICONV_RESULT_LAST);
	return iconv_error_strings[status];
}

namespace iconv_ffi {

	void* getExportsTable() {
		static struct static_iconv_exports_table exports = {
			.iconv_convert = &iconv_convert,
			.iconv_open = &iconv_open,
			.iconv_close = &iconv_close,
			.iconv = &iconv,
			.iconv_try_close = &iconv_try_close,
			.iconv_strerror = &iconv_strerror,
		};

		return &exports;
	}

}