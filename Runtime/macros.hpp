#pragma once

#define EXPAND_AS_STRING(x) #x
#define TOSTRING(x) EXPAND_AS_STRING(x)

#define FROM_HERE __FILE__ ":" TOSTRING(__LINE__)
