#include "crypto_ffi.hpp"
#include "crypto_argon2.hpp"

#include <openssl/core_names.h>
#include <openssl/crypto.h>
#include <openssl/err.h>
#include <openssl/evp.h>
#include <openssl/kdf.h>
#include <openssl/params.h>
#include <openssl/thread.h>

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

// Must match the number of parameters passed via kdf_parameters_t (plus end tag)
constexpr size_t NUM_SUPPORTED_KDF_PARAMS = 7 + 1;

void openssl_kdf_derive(kdf_input_t inputs, kdf_parameters_t parameters, kdf_result_t* result) {
	result->success = false;

	EVP_KDF* kdf = nullptr;
	EVP_KDF_CTX* kctx = nullptr;
	OSSL_PARAM params[NUM_SUPPORTED_KDF_PARAMS], *p = params;

	if(OSSL_set_max_threads(nullptr, parameters.threads) != 1) {
		std::cerr << "Failed to set_max_threads" << std::endl;
		goto fail;
	}

	p = params;
	*p++ = OSSL_PARAM_construct_octet_string(OSSL_KDF_PARAM_PASSWORD, const_cast<char*>(inputs.password), inputs.pw_length);
	*p++ = OSSL_PARAM_construct_octet_string(OSSL_KDF_PARAM_SALT, const_cast<char*>(inputs.salt), inputs.salt_length);
	*p++ = OSSL_PARAM_construct_uint32(OSSL_KDF_PARAM_ARGON2_VERSION, &parameters.version);
	*p++ = OSSL_PARAM_construct_uint32(OSSL_KDF_PARAM_ITER, &parameters.iterations);
	*p++ = OSSL_PARAM_construct_uint32(OSSL_KDF_PARAM_THREADS, &parameters.threads);
	*p++ = OSSL_PARAM_construct_uint32(OSSL_KDF_PARAM_ARGON2_LANES, &parameters.lanes);
	*p++ = OSSL_PARAM_construct_uint32(OSSL_KDF_PARAM_ARGON2_MEMCOST, &parameters.kilobytes);
	*p++ = OSSL_PARAM_construct_end();

	if((kdf = EVP_KDF_fetch(nullptr, parameters.kdf, nullptr)) == nullptr) {
		std::cerr << "Failed to fetch KDF " << parameters.kdf << std::endl;
		goto fail;
	}

	if((kctx = EVP_KDF_CTX_new(kdf)) == nullptr) {
		std::cerr << "Failed to create hashing context" << std::endl;
		goto fail;
	}

	if(EVP_KDF_derive(kctx, &result->hash[0], parameters.size, params) != 1) {
		std::cerr << "Failed to derive key" << std::endl;
		goto fail;
	}

	result->success = true;
	return;

fail:
	unsigned long error_code = ERR_get_error();
	ERR_error_string(error_code, result->message);
	std::cerr << "OpenSSL Error: " << result->message << std::endl;

	EVP_KDF_free(kdf);
	EVP_KDF_CTX_free(kctx);
	OSSL_set_max_threads(nullptr, 0);
}

namespace crypto_ffi {

	void* getExportsTable() {
		static struct static_crypto_exports_table exports = {
			.version_text = &getVersionText,
			.version_number = &getVersionNumber,

			.openssl_to_base64 = &openssl_to_base64,
			.openssl_from_base64 = &openssl_from_base64,
			.argon2_to_base64 = &argon2_to_base64,
			.argon2_from_base64 = &argon2_from_base64,
			.openssl_kdf_derive = &openssl_kdf_derive,
			.openssl_crypto_memcmp = &CRYPTO_memcmp,
		};

		return &exports;
	}

	const char* getVersionText() {
		return OPENSSL_VERSION_STR;
	}

	long int getVersionNumber() {
		return OPENSSL_VERSION_NUMBER;
	}
}