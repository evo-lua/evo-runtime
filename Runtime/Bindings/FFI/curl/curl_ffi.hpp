#pragma once

#include "curl.h"

typedef CURLU* url_ptr_t;
typedef const CURLU* url_cptr_t;

#include "curl_exports.h"

namespace curl_ffi {
	void* getExportsTable();
}