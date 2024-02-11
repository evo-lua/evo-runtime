#pragma once

#define EXPAND_AS_STRING(x) #x
#define TOSTRING(x) EXPAND_AS_STRING(x)

#define FROM_HERE __FILE__ ":" TOSTRING(__LINE__)

// Should replace this with std::embed (or even just C23 #embed) later
#define EMBED_BINARY(name, filename)                 \
	asm(".section .rodata\n"                         \
		"   .global " #name "\n" #name ":\n"         \
		"   .incbin " #filename "\n" #name "_end:\n" \
		"   .int  0\n"                               \
		"   .global " #name "_size\n"                \
		"   .type   " #name "_size, @object\n"       \
		"   .align 4\n" #name "_size:\n"             \
		"   .int  " #name "_end - " #name "\n"       \
		".section .text");                           \
	extern char name[];                              \
	extern unsigned name##_size;
