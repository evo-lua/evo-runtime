struct static_curl_exports_table {
	// curl.h
	CURLversion CURLVERSION_NOW;
	curl_version_info_data* (*curl_version_info)(CURLversion);
};