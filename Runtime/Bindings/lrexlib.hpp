#pragma once

#include "lua.hpp"

#define PCRE2_STATIC
#define PCRE2_CODE_UNIT_WIDTH 8

extern "C" {

// There's no header to include, so this is the best we can do
int luaopen_rex_pcre2(lua_State* L);
}