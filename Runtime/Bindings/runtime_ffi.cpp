#include "runtime_ffi.hpp"
#include "lua.hpp"
#include "macros.hpp"

extern "C" {
#include "luajit_repl.h"
}

#include <string>

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

#include "runtime_exports_generated.h"

	std::string getTypeDefinitions() {
		return std::string(*Runtime_Bindings_runtime_exports_h, Runtime_Bindings_runtime_exports_h_len);
	}

	void* getExportsTable() {
		static struct static_runtime_exports_table exports_table;

		// Build configuration
		exports_table.runtime_version = &runtime_version;

		// REPL
		exports_table.runtime_repl_start = &runtime_repl_start;

		return &exports_table;
	}

}