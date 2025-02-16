#pragma once

#include <cassert>

#define EXPAND_AS_STRING(x) #x
#define TOSTRING(x) EXPAND_AS_STRING(x)

#define FROM_HERE __FILE__ ":" TOSTRING(__LINE__)

// Silence [-Wunused-value] compiler warnings by adding (void)
#ifdef NDEBUG
#define ASSUME(condition, message) ((void)0)
#else
#define ASSUME(condition, failureMessage) assert((void(failureMessage), condition))
#endif