#pragma once

#include "curl.h"
#include "curl_exports.h"

namespace curl_ffi {
	void* getExportsTable();
}