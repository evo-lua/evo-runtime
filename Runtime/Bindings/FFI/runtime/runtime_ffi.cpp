#include "runtime_ffi.hpp"
#include "lua.hpp"

extern "C" {
#include "luajit_repl.h"
}

namespace runtime_ffi {
	lua_State* assignedLuaState;
	void assignLuaState(lua_State* L) {
		assignedLuaState = L;
	}

	const char* runtime_version() {
		return EVO_VERSION;
	}

	void runtime_repl_start() {
		dotty(assignedLuaState);
	}

	void* getExportsTable() {
		static struct static_runtime_exports_table exports = {
			// Build configuration
			.runtime_version = &runtime_version,

			// REPL
			.runtime_repl_start = &runtime_repl_start,
		};

		return &exports;
	}
}