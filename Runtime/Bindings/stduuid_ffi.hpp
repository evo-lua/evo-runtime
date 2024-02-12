#pragma once

#include <string>

#include "stduuid_exports.h"

bool uuid_create_v4(uuid_rfc_string_t* result);
bool uuid_create_mt19937(uuid_rfc_string_t* result);
bool uuid_create_v5(const char* namespace_uuid_str, const char* name, uuid_rfc_string_t* result);
bool uuid_create_system(uuid_rfc_string_t* result);

namespace stduuid_ffi {
	void* getExportsTable();
}