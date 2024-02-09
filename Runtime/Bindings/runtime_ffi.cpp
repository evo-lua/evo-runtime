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

	void runtime_repl_start() {
		dotty(assignedLuaState);
	}

	void* getExportsTable() {
		static struct static_runtime_exports_table exports_table;

		// REPL
		exports_table.runtime_repl_start = &runtime_repl_start;

		return &exports_table;
	}

}