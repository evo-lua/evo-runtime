#include "curl.h"
#include "curl_ffi.hpp"

#include <cstring> // strcopy

namespace curl_ffi {

	constexpr size_t MaxAllowedPartLength = 1024 * 4; // 8MB is allowed by libcurl, but that seems excessive
	// static char sharedHost[MaxAllowedPartLength];
	static char sharedPath[MaxAllowedPartLength];
	// static CURLU* sharedHandle; // TODO benchmark prealloc vs FFI/GC handle vs manual init/free
	constexpr int FEATURE_FLAGS_NONE = 0;

	// CURLUPART_URL,
	// CURLUPART_SCHEME,
	// CURLUPART_USER,
	// CURLUPART_PASSWORD,
	// CURLUPART_OPTIONS,
	// CURLUPART_HOST,
	// CURLUPART_PORT,
	// CURLUPART_PATH,
	// CURLUPART_QUERY,
	// CURLUPART_FRAGMENT,
	// CURLUPART_ZONEID /* added in 7.65.0 */

	static url_result_t result {
		// same for iconv (or general errtype system, only alloc one at a time)
		// TBD static lifetime questionable?
		.status = CURLUE_OK,
		.message = curl_url_strerror(CURLUE_OK), // Questionable/wasteful
		// TBD parts
		//.parts = ...
	};

	url_result_t* curl_decode_url(const char* url) { // TBD return cptr t instead

		CURLU* handle = curl_url();
		// assert(handle != nullptr);

		// Expensive AF - that doesn't seem right

		auto status = curl_url_set(handle, CURLUPART_URL, url, FEATURE_FLAGS_NONE);
		if(status != CURLUE_OK) {
			result.status = status,
			result.message = curl_url_strerror(status);
			return &result;
		}

		char* hostPtr;
		char* pathPtr;

		status = curl_url_get(handle, CURLUPART_HOST, &hostPtr, FEATURE_FLAGS_NONE);
		if(status != CURLUE_OK) { // goto fail etc. (DRY)
			result.status = status,
			result.message = curl_url_strerror(status);
			// curl_free ptrs...
			return &result;
		}

		status = curl_url_get(handle, CURLUPART_PATH, &pathPtr, FEATURE_FLAGS_NONE);
		if(status != CURLUE_OK) { // goto fail etc. (DRY)
			result.status = status,
			result.message = curl_url_strerror(status);
			// curl_free ptrs...
			return &result;
		}

		// Memcpy, free ? std::strcpy(sharedHost, hostPtr);
		std::strcpy(sharedPath, pathPtr);
		curl_free(hostPtr);
		curl_free(pathPtr);

		// return &sharedHost;
		return &result;

		// curl.bindings.curl_url_cleanup(handle) // Never, or appease the sanitizer? meh
	}

	void* getExportsTable() {
		static struct static_curl_exports_table exports = {
			// curl.h
			.CURLVERSION_NOW = CURLVERSION_NOW,
			.curl_version_info = curl_version_info,
			.curl_free = curl_free,
			// urlapi.h
			.curl_url = curl_url,
			.curl_url_cleanup = curl_url_cleanup,
			.curl_url_dup = curl_url_dup,
			.curl_url_get = curl_url_get,
			.curl_url_set = curl_url_set,
			.curl_url_strerror = curl_url_strerror,
			// custom
			.curl_decode_url = curl_decode_url,
		};

		return &exports;
	}
}