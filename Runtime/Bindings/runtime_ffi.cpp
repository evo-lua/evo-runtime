#include "runtime_ffi.hpp"
#include "lua.hpp"
#include "macros.hpp"

extern "C" {
#include "luajit_repl.h"
}

#include <string>

EMBED_BINARY(runtime_exported_types, "Runtime/Bindings/runtime_exports.h")

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

	std::string getTypeDefinitions() {
		return std::string(SYMBOL_NAME(runtime_exported_types));
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