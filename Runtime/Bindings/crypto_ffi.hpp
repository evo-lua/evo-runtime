#pragma once

#include <cstddef>
#include <cstdint>
#include <string>

#include "crypto_exports.h"

namespace crypto_ffi {

	std::string getTypeDefinitions();
	void* getExportsTable();
	const char* getVersionText();
	long int getVersionNumber();

}