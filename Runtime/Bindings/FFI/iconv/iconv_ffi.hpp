#pragma once

#include <cstddef>
#include <cstdint>

#include <iconv.h>
#include "iconv_exports.h"

namespace iconv_ffi {

	constexpr static const char* iconv_error_strings[ICONV_RESULT_LAST + 1] = {
		[ICONV_RESULT_OK] = "Success: Not an error",
		[ICONV_INVALID_REQUEST] = "Failed: Invalid conversion request",
		[ICONV_INVALID_DESCRIPTOR] = "Failed: Not a valid conversion descriptor",
		[ICONV_INVALID_INPUT] = "Failed: The provided input buffer is invalid, uninitialized, or has been corrupted",
		[ICONV_INVALID_OUTPUT] = "Failed: The provided output buffer is invalid, uninitialized, or has been corrupted",
		[ICONV_CONVERSION_FAILED] = "Failed: An invalid multibyte sequence was encountered within the input",
		[ICONV_INCOMPLETE_INPUT] = "Failed: The input ended prematurely or with an incomplete multibyte sequence",
		[ICONV_WRITEBUFFER_FULL] = "Failed: The provided output buffer is too small to store the conversion result",
		[ICONV_RESULT_LAST] = "Undefined: This should never happen",
	};

	void* getExportsTable();
}