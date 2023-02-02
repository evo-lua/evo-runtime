#include <stdio.h>
#include <string.h>

#include "webview_ffi.hpp"
#include "webview.h"

typedef void (*promise_function_t)(const char* seq, const char* req, void* arg);
typedef void (*webview_dispatch_function_t)(webview_t w, void* arg);

struct static_webview_exports_table {
	webview_t (*webview_create)(int debug, void* window);
	void (*webview_destroy)(webview_t w);
	void (*webview_run)(webview_t w);
	void (*webview_terminate)(webview_t w);
	void (*webview_dispatch)(webview_t w, webview_dispatch_function_t fn, void* arg);
	void* (*webview_get_window)(webview_t w);
	void (*webview_set_title)(webview_t w, const char* title);
	void (*webview_set_size)(webview_t w, int width, int height, int hints);
	void (*webview_navigate)(webview_t w, const char* url);
	void (*webview_set_html)(webview_t w, const char* html);
	void (*webview_init)(webview_t w, const char* js);
	void (*webview_eval)(webview_t w, const char* js);
	void (*webview_bind)(webview_t w, const char* name, promise_function_t fn, void* arg);
	void (*webview_unbind)(webview_t w, const char* name);
	void (*webview_return)(webview_t w, const char* seq, int status, const char* result);
	const webview_version_info_t* (*webview_version)(void);
};

namespace webview_ffi {
	void* getExportsTable() {
		static struct static_webview_exports_table webview_exports_table;

		webview_exports_table.webview_bind = webview_bind;
		webview_exports_table.webview_create = webview_create;
		webview_exports_table.webview_destroy = webview_destroy;
		webview_exports_table.webview_dispatch = webview_dispatch;
		webview_exports_table.webview_eval = webview_eval;
		webview_exports_table.webview_get_window = webview_get_window;
		webview_exports_table.webview_init = webview_init;
		webview_exports_table.webview_navigate = webview_navigate;
		webview_exports_table.webview_return = webview_return;
		webview_exports_table.webview_run = webview_run;
		webview_exports_table.webview_set_html = webview_set_html;
		webview_exports_table.webview_set_size = webview_set_size;
		webview_exports_table.webview_set_title = webview_set_title;
		webview_exports_table.webview_terminate = webview_terminate;
		webview_exports_table.webview_unbind = webview_unbind;
		webview_exports_table.webview_version = webview_version;

		return &webview_exports_table;
	}
}