#pragma once

#include <cstddef>
#include <cstdint>

#include <iconv.h>
#include "iconv_exports.h"

namespace iconv_ffi {
	constexpr std::size_t CHARSET_CONVERSION_FAILED = static_cast<size_t>(-1);

	void* getExportsTable();
}