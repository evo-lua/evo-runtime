#pragma once

#include <cstddef>
#include <cstdint>

#include <iconv.h>
#include "iconv_exports.h"

namespace iconv_ffi {
	constexpr std::array<const char*, ICONV_RESULT_LAST + 1> iconv_error_strings { {
		"Success: Not an error", // ICONV_RESULT_OK
		"Failed: Invalid conversion request", // ICONV_INVALID_REQUEST
		"Failed: Not a valid conversion descriptor", // ICONV_INVALID_HANDLE
		"Failed: Charset conversion failed", // ICONV_CONVERSION_FAILED
		"Failed: The provided input buffer is invalid, incomplete, or has been corrupted", // ICONV_INVALID_INPUT
		"Failed: The provided output buffer is invalid, incomplete, or has been corrupted", // ICONV_INVALID_OUTPUT
		"Failed: Use errno and strerror to retrieve the last system-level error", // ICONV_CHECK_ERRNO
		"Undefined: This should never happen" // ICONV_RESULT_LAST
	} };

	void* getExportsTable();
}