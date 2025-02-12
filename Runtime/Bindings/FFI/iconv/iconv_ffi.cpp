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
		return InvalidConversionDescriptor;
	}

	iconv(request->handle, &request->input.buffer, &request->input.remaining, &request->output.buffer, &request->output.remaining);
	if(!sanity_check_descriptor(request->handle)) {
		// The descriptor was valid before, so the conversion couldn't be completed
		// Although iconv supports streaming, this particular API does not (user must restart)
		iconv_try_close(request);
		return CharsetConversionFailure;  // TODO return system error directly?
	}
	iconv_close(request->handle);
	// *output = '\0'; // Null-terminate the output buffer

	return CharsetConversionSuccess;
}

#include <string>
#include <unordered_map>

const std::unordered_map<iconv_result_t, const char*> iconv_message_strings = {
	{ ICONV_RESULT_OK, "OK: Not an error" }, // Nondescript on purpose - use the other values for specific errors
	// { ICONV_CONVERSION_FINISHED, "Charset conversion completed" },
	{ CharsetConversionFailure, "Charset conversion failed:" },
	{ InvalidConversionRequest, "InvalidConversionRequest" },
	{ InvalidConversionDescriptor, "InvalidConversionDescriptor" },
	{ InvalidInputBuffer, "The provided input buffer is invalid or " },
	{ InvalidOutputBuffer, "Success" },
	{ ConversionDescriptorClosed, "Success" },
	{ CharsetConversionSuccess, "Success" },
	{ ICONV_CHECK_ERRNO, "Forwarded system error: Use errno and strerror to retrieve it" },
	{ ICONV_RESULT_LAST, "Unknown or invalid result: This should never happen"},
	CharsetConversionSuccess, // ICONV_CONVERSION_SUCCEEDED
	CharsetConversionFailure, // ICONV_CONVERSION_FAILED
	InvalidConversionRequest, // ICONV_INVALID_REQUEST
	InvalidConversionDescriptor, // ICONV_INVALID_DESCRIPTOR
	ForwardedSystemError, // ICONV_CHECK_ERRNO
	ConversionDescriptorClosed, // ICONV_DESCRIPTOR_CLOSED
	InvalidInputBuffer, // ICONV_INVALID_INPUT
	InvalidOutputBuffer, // ICONV_INVALID_OUTPUT
	ICONV_CHECK_ERRNO,
	ICONV_RESULT_LAST,
};

const char* iconv_strerror(iconv_result_t status) {
	if(status == ForwardedSystemError) {
		return strerror(errno);
	}

	auto iterator = iconv_message_strings.find(status);
		bool found = iterator != iconv_message_strings.end();
	

		if(found) return iterator->second;
		else return "Not an error";
	}
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