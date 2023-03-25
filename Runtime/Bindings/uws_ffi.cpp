#include "uws_ffi.hpp"

const char* uws_version() {
	return UWS_VERSION;
}

namespace uws_ffi {

	void* getExportsTable() {
		static struct static_uws_exports_table uwebsockets_exports_table;

		uwebsockets_exports_table.uws_version = uws_version;

		return &uwebsockets_exports_table;
	}
}