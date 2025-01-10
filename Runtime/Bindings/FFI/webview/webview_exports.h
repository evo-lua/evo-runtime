typedef void (*promise_function_t)(const char* seq, const char* req, void* arg);
typedef void (*webview_dispatch_function_t)(webview_t w, void* arg);

struct static_webview_exports_table {
	webview_t (*webview_create)(int debug, void* window);
	webview_error_t (*webview_destroy)(webview_t w);
	void (*webview_toggle_fullscreen)(webview_t w);
	webview_error_t (*webview_run)(webview_t w);
	int (*webview_run_once)(webview_t w, int blocking);
	webview_error_t (*webview_terminate)(webview_t w);
	webview_error_t (*webview_dispatch)(webview_t w, webview_dispatch_function_t fn, void* arg);
	void* (*webview_get_window)(webview_t w);
	webview_error_t (*webview_set_title)(webview_t w, const char* title);
	webview_error_t (*webview_set_size)(webview_t w, int width, int height, webview_hint_t hints);
	webview_error_t (*webview_navigate)(webview_t w, const char* url);
	webview_error_t (*webview_set_html)(webview_t w, const char* html);
	webview_error_t (*webview_init)(webview_t w, const char* js);
	webview_error_t (*webview_eval)(webview_t w, const char* js);
	webview_error_t (*webview_bind)(webview_t w, const char* name, promise_function_t fn, void* arg);
	webview_error_t (*webview_unbind)(webview_t w, const char* name);
	webview_error_t (*webview_return)(webview_t w, const char* seq, int status, const char* result);
	const webview_version_info_t* (*webview_version)(void);
	bool (*webview_set_icon)(webview_t w, const char* file_path);
	void* (*webview_get_native_handle)(webview_t w, webview_native_handle_kind_t kind);
};