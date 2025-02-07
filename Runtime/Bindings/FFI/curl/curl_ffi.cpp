#include "curl.h"
#include "curl_ffi.hpp"

namespace curl_ffi {
	void* getExportsTable() {
		static struct static_curl_exports_table exports = {
			// curl.h
			.CURLVERSION_NOW = CURLVERSION_NOW,
			.curl_version_info = curl_version_info,
			.curl_free = curl_free,
			// urlapi.h
			.curl_url = curl_url,
			.curl_url_cleanup = curl_url_cleanup,
			.curl_url_set = curl_url_set,
			.curl_url_get = curl_url_get
		};

		return &exports;
	}
}