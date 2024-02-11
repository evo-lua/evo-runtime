#pragma once

#include <cstddef>
#include <cstdint>

#include "crypto_exports.h"

namespace crypto_ffi {

	const char* getTypeDefinitions();
	void* getExportsTable();
	const char* getVersionText();
	long int getVersionNumber();

}