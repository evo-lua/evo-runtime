#pragma once

#include <cstddef>
#include <cstdint>

typedef struct kdf_parameters_t {
	const char* kdf;
	uint32_t version;
	uint32_t kilobytes;
	uint32_t threads;
	uint32_t lanes;
	size_t size;
	uint32_t iterations;
} kdf_parameters_t;

typedef struct kdf_input_t {
	const char* password;
	size_t pw_length;
	const char* salt;
	size_t salt_length;
} kdf_input_t;

typedef struct kdf_result_t {
	bool success;
	unsigned char* hash;
	char* message;
} kdf_result_t;

struct static_crypto_exports_table {
	// OpenSSL (libcrypto) metadata
	const char* (*version_text)(void);
	long int (*version_number)(void);

	// Argon2 MCF utilities
	size_t (*openssl_to_base64)(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len);
	size_t (*openssl_from_base64)(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len);
	size_t (*argon2_to_base64)(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len);
	size_t (*argon2_from_base64)(unsigned char* dst, size_t dst_len, const char* src);
	void (*openssl_kdf_derive)(kdf_input_t inputs, kdf_parameters_t parameters, kdf_result_t* result);

	int (*openssl_crypto_memcmp)(const void* a, const void* b, size_t len);
};

namespace crypto_ffi {

	void* getExportsTable();
	const char* getVersionText();
	long int getVersionNumber();

}