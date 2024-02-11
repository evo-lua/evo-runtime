#pragma once

#include "lua.hpp"

#include "runtime_exports.h"

namespace runtime_ffi {
	void assignLuaState(lua_State* L);

	// Build configuration
	const char* runtime_version();

	// REPL
	void runtime_repl_start();

	const char* getTypeDefinitions();
	void* getExportsTable();
}
