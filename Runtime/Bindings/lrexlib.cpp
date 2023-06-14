#include "lrexlib.hpp"

// LREXLIB requires a VERSION define, which would be set by luarocks if we used that... but we don't (and it's not needed anyway)
#define VERSION "0.0.0"

// lrexlib assigns both unsigned and signed PCRE flags to the same flag_pair struct, which only carries ints :/
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wnarrowing"

extern "C" {
// lrexlib doesn't have a Windows-compatible build system, so this just lives here now...
#include <rrthomas/lrexlib/src/common.c>
#include <rrthomas/lrexlib/src/pcre2/lpcre2.c>
#include <rrthomas/lrexlib/src/pcre2/lpcre2_f.c>
}

#pragma GCC diagnostic pop
#undef VERSION