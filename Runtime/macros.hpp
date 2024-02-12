#pragma once

#define EXPAND_AS_STRING(x) #x
#define TOSTRING(x) EXPAND_AS_STRING(x)

#define FROM_HERE __FILE__ ":" TOSTRING(__LINE__)

// Should replace this with std::embed (or even just C23 #embed) later
#if defined(__APPLE__)
#define SYMBOL_NAME(name) name
#define EMBED_BINARY(name, filename)                 \
	__asm__(".section __DATA,__rodata\n"             \
			"   .globl _" #name "\n"                 \
			"_" #name ":\n"                          \
			"   .incbin \"" filename "\"\n"          \
			"_" #name "_end:\n"                      \
			"   .byte 0\n"                           \
			"   .align 4\n"                          \
			"   .globl _" #name "_size\n"            \
			"   .p2align 2\n"                        \
			"_" #name "_size:\n"                     \
			"   .long _" #name "_end - _" #name "\n" \
			".section __TEXT,__text");               \
	extern const char _##name[];                     \
	extern const unsigned int _##name##_size;
#elif defined(__linux__)
#define SYMBOL_NAME(name) name
#define EMBED_BINARY(name, filename)                        \
	__asm__(".section .rodata\n"                            \
			"   .globl " #name "\n" #name ":\n"             \
			"   .incbin \"" filename "\"\n" #name "_end:\n" \
			"   .byte 0\n"                                  \
			"   .align 4\n"                                 \
			"   .globl " #name "_size\n"                    \
			"   .type " #name "_size, @object\n"            \
			"   .size " #name "_size, . - " #name "\n"      \
			".section .text");                              \
	extern const char name[];                               \
	extern const unsigned int name##_size;
#else
#define SYMBOL_NAME(name) name
#define EMBED_BINARY(name, filename)                        \
	__asm__(".section .rodata\n"                            \
			"   .globl " #name "\n" #name ":\n"             \
			"   .incbin \"" filename "\"\n" #name "_end:\n" \
			"   .byte 0\n"                                  \
			"   .align 4\n");                               \
	extern const char name[];                               \
	extern const unsigned int name##_size;
#endif
