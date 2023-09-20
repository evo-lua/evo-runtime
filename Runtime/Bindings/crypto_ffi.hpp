#pragma once

#include <cstddef>

struct static_crypto_exports_table {
	// OpenSSL (libcrypto) metadata
	const char* (*version_text)(void);
	long int (*version_number)(void);

	// Argon2 MCF utilities
	size_t (*openssl_to_base64)(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len);
	size_t (*openssl_from_base64)(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len);
	size_t (*argon2_to_base64)(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len);
	size_t (*argon2_from_base64)(unsigned char* dst, size_t dst_len, const char* src);
};

namespace crypto_ffi {

	typedef enum {
		KDF_ARGON2ID,
		KDF_ARGON2D,
		KDF_ARGON2I,
	} KEY_DERIVATION_FUNCTIONS;

	void* getExportsTable();
	const char* getVersionText();
	long int getVersionNumber();

}