local bindings = require("bindings")
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

]] .. bindings.webview.cdefs

function webview.initialize()
	ffi.cdef(webview.cdefs)
end

function webview.version()
	local versionInfo = webview.bindings.webview_version()
	local luaVersionString = ffi.string(versionInfo.version_number)
	return luaVersionString
end

return webview
