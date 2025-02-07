struct static_curl_exports_table {
	// curl.h
	CURLversion CURLVERSION_NOW;
	curl_version_info_data* (*curl_version_info)(CURLversion);
	void (*curl_free)(void*);
	// urlapi.h
	url_ptr_t (*curl_url)(void);
	void (*curl_url_cleanup)(url_ptr_t);
	CURLUcode (*curl_url_set)(url_ptr_t url,
		CURLUPart part,
		const char* content,
		unsigned int flags);
	CURLUcode (*curl_url_get)(url_cptr_t url,
		CURLUPart part,
		char** content,
		unsigned int flags);
};