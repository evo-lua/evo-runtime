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

	void repl_start() {
		dotty(assignedLuaState);
	}

	void* getExportsTable() {
		static struct static_runtime_exports_table exports_table;

		// Build configuration
		exports_table.runtime_version = &runtime_version;

		// REPL
		exports_table.repl_start = &repl_start;

		return &exports_table;
	}

}