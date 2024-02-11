#pragma once

#define EXPAND_AS_STRING(x) #x
#define TOSTRING(x) EXPAND_AS_STRING(x)

#define FROM_HERE __FILE__ ":" TOSTRING(__LINE__)

// Should replace this with std::embed (or even just C23 #embed) later
#if defined(__clang__) && defined(__APPLE__)
// Apple clang (macOS)
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
	extern "C" {                                     \
	extern const char _##name;                       \
	extern const unsigned int _##name##_size;        \
	}
#else
// GCC (Windows or Linux)
#define EMBED_BINARY(name, filename)                    \
	asm(".section .rodata\n"                            \
		"   .global " #name "\n" #name ":\n"            \
		"   .incbin \"" filename "\"\n" #name "_end:\n" \
		"   .int  0\n"                                  \
		"   .global " #name "_size\n"                   \
		"   .type   " #name "_size, @object\n"          \
		"   .align 4\n" #name "_size:\n"                \
		"   .int  " #name "_end - " #name "\n"          \
		".section .text");                              \
	extern char name[];                                 \
	extern unsigned name##_size;
#endif
