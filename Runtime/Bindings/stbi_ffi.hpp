#pragma once

#include <cstdint>
#include <cstddef>

#include "stbi_exports.h"

namespace stbi_ffi {
	const char* getTypeDefinitions();
	void* getExportsTable();
}