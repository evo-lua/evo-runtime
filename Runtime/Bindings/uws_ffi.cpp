// These have to be included directly since uws is a header-only library
#include <App.h>

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

	void assignEventLoop(void* existing_native_loop) {
		uWS::Loop::get(existing_native_loop); // Actually: Assign and then return
	}

}