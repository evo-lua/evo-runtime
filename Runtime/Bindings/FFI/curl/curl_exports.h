typedef struct url_parts_t {
	// TBD preallocation seems like overkill?
} url_parts_t;

typedef struct url_result_t {
	int status;
	const char* message;
} url_result_t;

struct static_curl_exports_table {
	// curl.h
	CURLversion CURLVERSION_NOW;
	curl_version_info_data* (*curl_version_info)(CURLversion);
	void (*curl_free)(void*);
	// urlapi.h
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
	const char* (*curl_url_strerror)(CURLUcode errno);
	// custom
	url_result_t* (*curl_decode_url)(const char* url); // TODO: Remove (doesn't seem much faster, needs alloc optimizations = deferred until later)
};