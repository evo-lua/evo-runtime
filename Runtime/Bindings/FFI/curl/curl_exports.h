struct static_curl_exports_table {
	// Exports from curl.h
	CURLversion (*curl_version_now)(void);
	curl_version_info_data* (*curl_version_info)(CURLversion);
	void (*curl_free)(void*);

	// Exports from easy.h
	void (*curl_easy_cleanup)(CURL* handle);
	CURL* (*curl_easy_duphandle)(CURL* handle);
	char* (*curl_easy_escape)(CURL* handle, const char* string, int length);
	// CURLcode (*curl_easy_getinfo)(CURL* handle, CURLINFO info, ...);
	CURLHcode (*curl_easy_header)(CURL* handle,
		const char* name,
		size_t index,
		unsigned int origin,
		int request,
		struct curl_header** hout);
	CURL* (*curl_easy_init)(void);
	struct curl_header* (*curl_easy_nextheader)(CURL* handle,
		unsigned int origin,
		int request,
		struct curl_header* prev);
	// const struct curl_easyoption* (*curl_easy_option_by_id)(CURLoption id);
	const struct curl_easyoption* (*curl_easy_option_by_name)(const char* name);
	const struct curl_easyoption* (*curl_easy_option_next)(const struct curl_easyoption* prev);
	CURLcode (*curl_easy_pause)(CURL* handle, int bitmask);
	CURLcode (*curl_easy_perform)(CURL* handle);
	CURLcode (*curl_easy_recv)(CURL* handle, void* buffer, size_t buflen, size_t* n);
	void (*curl_easy_reset)(CURL* handle);
	CURLcode (*curl_easy_send)(CURL* handle, const void* buffer, size_t buflen, size_t* n);
	CURLcode (*curl_easy_setopt)(CURL* handle, const struct curl_easyoption* option, ...);
	CURLcode (*curl_easy_ssls_import)(CURL* handle,
		const char* session_key,
		const unsigned char* shmac,
		size_t shmac_len,
		const unsigned char* sdata,
		size_t sdata_len);
	CURLcode (*curl_easy_ssls_export)(CURL* handle,
		curl_ssls_export_cb* export_fn,
		void* userptr);
	const char* (*curl_easy_strerror)(CURLcode status);
	char* (*curl_easy_unescape)(CURL* handle, const char* input,
		int inlength, int* outlength);
	CURLcode (*curl_easy_upkeep)(CURL* handle);

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