#include "iconv_ffi.hpp"
#include "macros.hpp"

#include <iostream>
#include <stdint.h>
#include <string.h>

#include <iconv.h>

namespace iconv_ffi {

	constexpr size_t ICONV_INVALID_HANDLE = SIZE_MAX;
	constexpr size_t ICONV_INVALID_SIZE = SIZE_MAX;
	bool sanity_check_descriptor(const iconv_t& handle) {
		return reinterpret_cast<size_t>(handle) != ICONV_INVALID_HANDLE;
	}

	inline bool sanity_check_buffer(const iconv_memory_t* workload) {
		if(workload->buffer == nullptr) return false;

		ASSUME(workload->remaining >= workload->length, "Cursors should never escape the memory field");
		if(workload->remaining > workload->length) return false;

		return true;
	}

	bool iconv_check_result(iconv_t handle) {
		return sanity_check_descriptor(handle);
	}

	const char* iconv_strerror(iconv_result_t status) {
		status = std::min(status, ICONV_RESULT_LAST);
		// Compilation seems to always fail for nontrivial initializers, but maybe that'll change in the future...
		ASSUME(iconv_error_strings[status] != nullptr, "Error strings should be defined for all possible results");
		return iconv_error_strings[status];
	}

	iconv_result_t iconv_check_errno() {
		auto status = errno;

		// 1. An invalid multibyte sequence is encountered in the input
		// 2. A multibyte sequence is encountered that is valid but that cannot be translated
		// Apparently there's no way to differentiate between these two failure scenarios :/
		if(status == EILSEQ) return ICONV_CONVERSION_FAILED;
		// 4. An incomplete multibyte sequence is encountered in the input [and there are no more bytes available]
		if(status == EINVAL) return ICONV_INCOMPLETE_INPUT;
		// 5. The output buffer has no more room for the next converted character
		if(status == E2BIG) return ICONV_WRITEBUFFER_FULL;

		// Fall through to help detect API contract violations
		return ICONV_RESULT_LAST;
	}

	iconv_result_t iconv_try_close(iconv_request_t* request) {
		if(request == nullptr) return ICONV_INVALID_REQUEST;
		if(request->handle == nullptr) return ICONV_INVALID_DESCRIPTOR;

		// MINGW64's iconv implementation can't handle closing invalid descriptors
		if(!sanity_check_descriptor(request->handle)) {
			return ICONV_INVALID_DESCRIPTOR;
		}

		int result = iconv_close(request->handle);
		ASSUME(result == 0, "Calling iconv_close should never fail");
		if(result != 0) return iconv_check_errno(); // Shouldn't be possible, but you never know...

		return ICONV_RESULT_OK;
	}

	iconv_result_t iconv_convert(iconv_request_t* request) {
		if(request == nullptr) return ICONV_INVALID_REQUEST;

		if(!sanity_check_buffer(&request->input)) {
			return ICONV_INVALID_INPUT;
		};

		if(!sanity_check_buffer(&request->output)) {
			return ICONV_INVALID_OUTPUT;
		};

		// This currently fails if an invalid charset identifier is provided -> Fix later so the error is unique
		request->handle = iconv_open(request->output.charset, request->input.charset);
		if(!sanity_check_descriptor(request->handle)) {
			return iconv_check_errno();
		}

		size_t numBytesIrreversiblyWritten = iconv(request->handle, &request->input.buffer, &request->input.remaining, &request->output.buffer, &request->output.remaining);
		if(numBytesIrreversiblyWritten == ICONV_INVALID_SIZE) {
			return iconv_check_errno();
		}

		if(!sanity_check_descriptor(request->handle)) {
			// Clearly the handle was valid before, so the request couldn't be completed (caller should close or retry)
			auto result = iconv_check_errno();
			ASSUME(iconv_try_close(request) == ICONV_INVALID_DESCRIPTOR, "Closing an invalid handle should be a NOOP");
			return result;
		}
		auto result = iconv_try_close(request);
		ASSUME(result == ICONV_RESULT_OK, "Closing a valid handle should never fail");
		return result;
	}

	void* getExportsTable() {

		static struct static_iconv_exports_table exports = {

			// Exports from iconv.h
			.iconv_open = &iconv_open,
			.iconv_close = &iconv_close,
			.iconv = &iconv,

			// Charset conversion API
			.iconv_convert = &iconv_convert,
			.iconv_try_close = &iconv_try_close,

			// Utility methods
			.iconv_strerror = &iconv_strerror,
			.iconv_check_result = &iconv_check_result,
		};

		return &exports;
	}

}