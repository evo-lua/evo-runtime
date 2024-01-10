#pragma once

#include "lua.hpp"

extern "C" {
// There's no header to include, so this is the best we can do
int luaopen_lpeg(lua_State* L);
}