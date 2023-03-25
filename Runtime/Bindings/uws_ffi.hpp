#pragma once

struct static_uws_exports_table {
	const char* (*uws_version)(void);
};

namespace uws_ffi{
	void* getExportsTable();
}