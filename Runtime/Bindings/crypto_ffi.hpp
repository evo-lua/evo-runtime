#pragma once

#include <cstddef>
#include <cstdint>

#include "crypto_exports.h"

namespace crypto_ffi {

	void* getExportsTable();
	const char* getVersionText();
	long int getVersionNumber();

}