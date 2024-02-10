#pragma once

#include "lua.hpp"

struct static_runtime_exports_table {
	// Build configuration
	const char* (*runtime_version)(void);

	// REPL
	void (*runtime_repl_start)(void);
};

namespace runtime_ffi {
	void assignLuaState(lua_State* L);

	// Build configuration
	const char* runtime_version();

	// REPL
	void runtime_repl_start();

	void* getExportsTable();
}
