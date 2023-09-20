#include "crypto_ffi.hpp"
#include "crypto_argon2.hpp"

#include <openssl/evp.h>

#include <cstddef>
#include <iostream>

size_t openssl_to_base64(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len) {
	EVP_ENCODE_CTX* ctx = EVP_ENCODE_CTX_new();
	if(!ctx) return 0;

	int out_len = 0, tmp_len = 0;

	EVP_EncodeInit(ctx);
	EVP_EncodeUpdate(ctx, dst, &out_len, src, src_len);
	EVP_EncodeFinal(ctx, static_cast<unsigned char*>(dst + out_len), &tmp_len);

	out_len += tmp_len;
	EVP_ENCODE_CTX_free(ctx);

	return out_len;
}

size_t openssl_from_base64(unsigned char* dst, size_t dst_len, const unsigned char* src, size_t src_len) {
	EVP_ENCODE_CTX* ctx = EVP_ENCODE_CTX_new();
	if(!ctx) return 0;

	int out_len = 0, tmp_len = 0;

	EVP_DecodeInit(ctx);
	if(EVP_DecodeUpdate(ctx, dst, &out_len, src, src_len) == -1) {
		EVP_ENCODE_CTX_free(ctx);
		return 0;
	}
	if(EVP_DecodeFinal(ctx, static_cast<unsigned char*>(dst + out_len), &tmp_len) == -1) {
		EVP_ENCODE_CTX_free(ctx);
		return 0;
	}

	out_len += tmp_len;
	EVP_ENCODE_CTX_free(ctx);

	return out_len;
}

namespace crypto_ffi {

	void* getExportsTable() {
		static struct static_crypto_exports_table exports_table;

		exports_table.version_text = &getVersionText;
		exports_table.version_number = &getVersionNumber;

		exports_table.openssl_to_base64 = &openssl_to_base64;
		exports_table.openssl_from_base64 = &openssl_from_base64;
		exports_table.argon2_to_base64 = &argon2_to_base64;
		exports_table.argon2_from_base64 = &argon2_from_base64;

		return &exports_table;
	}

	const char* getVersionText() {
		std::cout << OPENSSL_VERSION_TEXT << std::endl;
		return OPENSSL_VERSION_TEXT;
	}

	long int getVersionNumber() {
		std::cout << OPENSSL_VERSION_NUMBER << std::endl;
		return OPENSSL_VERSION_NUMBER;
	}
}