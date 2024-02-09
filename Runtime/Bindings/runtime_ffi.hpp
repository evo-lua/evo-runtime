#pragma once

#include "lua.hpp"

struct static_runtime_exports_table {
	void (*runtime_repl_start)(void);
};

namespace runtime_ffi {
	void assignLuaState(lua_State* L);

	// REPL
	void runtime_repl_start();

	void* getExportsTable();
}
