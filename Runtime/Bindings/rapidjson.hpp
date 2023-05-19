// lua-rapidjson only supports DLL builds and there are no headers...
#include "lua.hpp"

extern "C" {
int luaopen_rapidjson(lua_State* L);
}