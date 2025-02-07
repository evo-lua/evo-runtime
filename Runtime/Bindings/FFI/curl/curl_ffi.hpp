#pragma once

#include "curl.h"

typedef CURLU* url_handle_t;

#include "curl_exports.h"

namespace curl_ffi {
	void* getExportsTable();
}