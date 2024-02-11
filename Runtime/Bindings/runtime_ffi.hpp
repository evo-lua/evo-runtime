#pragma once

#include "lua.hpp"

#include <string>

#include "runtime_exports.h"

namespace runtime_ffi {
	void assignLuaState(lua_State* L);

	// Build configuration
	const char* runtime_version();

	// REPL
	void runtime_repl_start();

	std::string getTypeDefinitions();
	void* getExportsTable();
}
