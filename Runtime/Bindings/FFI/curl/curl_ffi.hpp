#pragma once

#include "curl.h"
#include "curl_exports.h"

typedef CURLU* url_handle_t;

namespace curl_ffi {
	void* getExportsTable();
}