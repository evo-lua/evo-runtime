struct static_curl_exports_table {
	// curl.h
	CURLversion CURLVERSION_NOW;
	curl_version_info_data* (*curl_version_info)(CURLversion);

	// urlapi.h
	CURLU (*curl_url)(void);
	void (*curl_url_cleanup)(CURLU);
	CURLUcode (*curl_url_set)(CURLU* url,
		CURLUPart part,
		const char* content,
		unsigned int flags);
	CURLUcode (*curl_url_get)(const CURLU* url,
		CURLUPart part,
		char** content,
		unsigned int flags);
};