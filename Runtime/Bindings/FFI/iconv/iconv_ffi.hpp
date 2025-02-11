#pragma once

#include <cstddef>
#include <cstdint>

#include <iconv.h>
#include "iconv_exports.h"

namespace iconv_ffi {
	void* getExportsTable();
}