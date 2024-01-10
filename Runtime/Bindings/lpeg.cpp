#include <lpeg.hpp>

// Workaround: LPEG redefines the LuaJIT macro, so better restore it (eliminates the compiler warning)
#ifdef luaL_newlib
#define luaL_newlib_backup
#undef luaL_newlib
#endif

// LPEG doesn't support static builds, so this questionable hack will have to do
#include <roberto-ieru/LPeg/lpvm.c>
#include <roberto-ieru/LPeg/lpcap.c>
#include <roberto-ieru/LPeg/lptree.c>
#include <roberto-ieru/LPeg/lpcode.c>
#include <roberto-ieru/LPeg/lpprint.c>
#include <roberto-ieru/LPeg/lpcset.c>

#undef luaL_newlib
#define luaL_newlib luaL_newlib_backup
#undef luaL_newlib_backup