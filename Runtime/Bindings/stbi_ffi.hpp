#pragma once

#include <cstdint>
#include <cstddef>
#include <string>

#include "stbi_exports.h"

namespace stbi_ffi {
	std::string getTypeDefinitions();
	void* getExportsTable();
}