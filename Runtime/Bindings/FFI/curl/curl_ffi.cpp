#include "curl_ffi.hpp"

#include <stdexcept>

namespace curl_ffi {
	CURLversion curl_version_now() {
		return CURLVERSION_NOW;
	}

	CURLcode curl_easy_setopt_by_name(CURL* handle, const struct curl_easyoption* option, ...) {
		throw std::runtime_error("NYI: Call curl_easy_setopt with the appropriate curl_easyoption ID");
		return CURLE_OK;
	}

	void* getExportsTable() {
		static struct static_curl_exports_table exports = {
			// Exports from curl.h
			.curl_version_now = curl_version_now,
			.curl_version_info = curl_version_info,
			.curl_free = curl_free,

			// Exports from easy.h
			.curl_easy_cleanup = curl_easy_cleanup,
			.curl_easy_duphandle = curl_easy_duphandle,
			.curl_easy_escape = curl_easy_escape,
			// .curl_easy_getinfo = curl_easy_getinfo,
			.curl_easy_header = curl_easy_header,
			.curl_easy_init = curl_easy_init,
			.curl_easy_nextheader = curl_easy_nextheader,
			// .curl_easy_option_by_id = curl_easy_option_by_id,
			.curl_easy_option_by_name = curl_easy_option_by_name,
			.curl_easy_option_next = curl_easy_option_next,
			.curl_easy_pause = curl_easy_pause,
			.curl_easy_perform = curl_easy_perform,
			.curl_easy_recv = curl_easy_recv,
			.curl_easy_reset = curl_easy_reset,
			.curl_easy_send = curl_easy_send,
			.curl_easy_setopt = curl_easy_setopt_by_name,
			.curl_easy_ssls_import = curl_easy_ssls_import,
			.curl_easy_ssls_export = curl_easy_ssls_export,
			.curl_easy_strerror = curl_easy_strerror,
			.curl_easy_unescape = curl_easy_unescape,
			.curl_easy_upkeep = curl_easy_upkeep,

			// Exports from urlapi.h
			.curl_url = curl_url,
			.curl_url_cleanup = curl_url_cleanup,
			.curl_url_dup = curl_url_dup,
			.curl_url_get = curl_url_get,
			.curl_url_set = curl_url_set,
			.curl_url_strerror = curl_url_strerror,
		};

		return &exports;
	}
}