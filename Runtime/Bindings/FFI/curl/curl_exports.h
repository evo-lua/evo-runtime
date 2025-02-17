struct static_curl_exports_table {
	// Exports from curl.h
	CURLversion (*curl_version_now)(void);
	curl_version_info_data* (*curl_version_info)(CURLversion);
	void (*curl_free)(void*);

	// Exports from urlapi.h
	url_ptr_t (*curl_url)(void);
	void (*curl_url_cleanup)(url_ptr_t handle);
	url_ptr_t (*curl_url_dup)(url_cptr_t handle);
	CURLUcode (*curl_url_get)(url_cptr_t handle,
		CURLUPart what,
		char** part,
		unsigned int flags);
	CURLUcode (*curl_url_set)(url_ptr_t handle,
		CURLUPart what,
		const char* part,
		unsigned int flags);
	const char* (*curl_url_strerror)(CURLUcode status);
};