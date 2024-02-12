#pragma once

#include <cstddef>
#include <cstdint>
#include <string.h>
#include <string>

#include "iconv_exports.h"

namespace iconv_ffi {
	void* getExportsTable();
}