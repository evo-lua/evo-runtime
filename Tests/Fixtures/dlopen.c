#if defined(_WIN32) || defined(_WIN64)
#define EXPORT __declspec(dllexport)
#else
#define EXPORT __attribute__((visibility("default")))
#endif

#include <stdint.h>
#include <stdio.h>

EXPORT uint32_t vfs_dlopen_test(uint32_t input) {
	printf("vfs_dlopen_test called from VFS with input: %u\n", input);
	return input * 2;
}
