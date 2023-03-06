local ffi = require("ffi")

local uwebsockets = {}

uwebsockets.cdefs = [[

	typedef void *uwebsockets_t;

	typedef void (*promise_function_t)(const char *seq, const char *req, void *arg);
	typedef void (*uwebsockets_dispatch_function_t)(uwebsockets_t w, void *arg);

	typedef struct {
	  unsigned int major;
	  unsigned int minor;
	  unsigned int patch;
	} uwebsockets_version_t;

	typedef struct {
	  uwebsockets_version_t version;
	  char version_number[32];
	  char pre_release[48];
	  char build_metadata[48];
	} uwebsockets_version_info_t;

	struct static_uws_exports_table {
		uwebsockets_t (*uwebsockets_create)(int debug, void *window);
		void (*uwebsockets_destroy)(uwebsockets_t w);
		void (*uwebsockets_run)(uwebsockets_t w);
		int (*uwebsockets_run_once)(uwebsockets_t w, int blocking);
		void (*uwebsockets_terminate)(uwebsockets_t w);
		void (*uwebsockets_dispatch)(uwebsockets_t w, uwebsockets_dispatch_function_t fn, void *arg);
		void *(*uwebsockets_get_window)(uwebsockets_t w);
		void (*uwebsockets_set_title)(uwebsockets_t w, const char *title);
		void (*uwebsockets_set_size)(uwebsockets_t w, int width, int height, int hints);
		void (*uwebsockets_navigate)(uwebsockets_t w, const char *url);
		void (*uwebsockets_set_html)(uwebsockets_t w, const char *html);
		void (*uwebsockets_init)(uwebsockets_t w, const char *js);
		void (*uwebsockets_eval)(uwebsockets_t w, const char *js);
		void (*uwebsockets_bind)(uwebsockets_t w, const char *name, promise_function_t fn, void *arg);
		void (*uwebsockets_unbind)(uwebsockets_t w, const char *name);
		void (*uwebsockets_return)(uwebsockets_t w, const char *seq, int status, const char *result);
		const uwebsockets_version_info_t* (*uwebsockets_version)(void);
	};
]]

function uwebsockets.initialize()
	ffi.cdef(uwebsockets.cdefs)
end

function uwebsockets.version()
	-- local versionInfo = uwebsockets.bindings.uwebsockets_version()
	-- local luaVersionString = ffi.string(versionInfo.version_number)
	-- return luaVersionString
end

return uwebsockets
