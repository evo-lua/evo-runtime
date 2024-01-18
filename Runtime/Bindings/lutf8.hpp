#pragma once

#include "lua.hpp"

extern "C" {
// There's no header to include, so this is the best we can do
int luaopen_utf8(lua_State* L);
}
