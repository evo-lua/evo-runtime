local ffi = require("ffi")

local webview = {}

webview.cdefs = [[

	typedef void *webview_t;

	typedef void (*promise_function_t)(const char *seq, const char *req, void *arg);
	typedef void (*webview_dispatch_function_t)(webview_t w, void *arg);

	typedef struct {
	  unsigned int major;
	  unsigned int minor;
	  unsigned int patch;
	} webview_version_t;

	typedef struct {
	  webview_version_t version;
	  char version_number[32];
	  char pre_release[48];
	  char build_metadata[48];
	} webview_version_info_t;

	struct static_webview_exports_table {
		webview_t (*webview_create)(int debug, void *window);
		void (*webview_destroy)(webview_t w);
		void (*webview_run)(webview_t w);
		void (*webview_terminate)(webview_t w);
		void (*webview_dispatch)(webview_t w, webview_dispatch_function_t fn, void *arg);
		void *(*webview_get_window)(webview_t w);
		void (*webview_set_title)(webview_t w, const char *title);
		void (*webview_set_size)(webview_t w, int width, int height, int hints);
		void (*webview_navigate)(webview_t w, const char *url);
		void (*webview_set_html)(webview_t w, const char *html);
		void (*webview_init)(webview_t w, const char *js);
		void (*webview_eval)(webview_t w, const char *js);
		void (*webview_bind)(webview_t w, const char *name, promise_function_t fn, void *arg);
		void (*webview_unbind)(webview_t w, const char *name);
		void (*webview_return)(webview_t w, const char *seq, int status, const char *result);
		const webview_version_info_t* (*webview_version)(void);
	};
]]

function webview.initialize()
	ffi.cdef(webview.cdefs)
end

function webview.version()
	local versionInfo = webview.bindings.webview_version()
	local luaVersionString = ffi.string(versionInfo.version_number)
	return luaVersionString
end

return webview
