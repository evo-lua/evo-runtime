#include <stdio.h>
#include <string.h>

#include "webview.h"
#include "webview_exports.h"
#include "webview_ffi.hpp"

namespace webview_ffi {
	// Note: This is an implementation detail and not part of the public API
	auto unwrapResult(auto result) {
		result.ensure_ok();
		return result.value();
	}
}

#ifdef __unix__
#include "webview_unix.hpp"
#endif

#ifdef __APPLE__
#include "webview_mac.hpp"
#endif

#ifdef __WIN32__
#include "webview_windows.hpp"
#endif

namespace webview_ffi {
	webview_t webview_create(int withDevToolsEnabled, void* existingNativeWindow) {
		return new WebviewBrowserEngine(withDevToolsEnabled, existingNativeWindow);
	}

	int webview_run_once(webview_t w, int blocking) {
		return static_cast<WebviewBrowserEngine*>(w)->step(blocking);
	}

	void webview_toggle_fullscreen(webview_t w) {
		static_cast<WebviewBrowserEngine*>(w)->toggleFullScreen();
	}

	bool webview_set_icon(webview_t w, const char* file_path) {
		return static_cast<WebviewBrowserEngine*>(w)->setAppIcon(file_path);
	}

	void* getExportsTable() {
		static struct static_webview_exports_table exports = {
			.webview_create = webview_create,
			.webview_destroy = webview_destroy,
			.webview_toggle_fullscreen = webview_toggle_fullscreen,
			.webview_run = webview_run,
			.webview_run_once = webview_run_once,
			.webview_terminate = webview_terminate,
			.webview_dispatch = webview_dispatch,
			.webview_get_window = webview_get_window,
			.webview_set_title = webview_set_title,
			.webview_set_size = webview_set_size,
			.webview_navigate = webview_navigate,
			.webview_set_html = webview_set_html,
			.webview_init = webview_init,
			.webview_eval = webview_eval,
			.webview_bind = webview_bind,
			.webview_unbind = webview_unbind,
			.webview_return = webview_return,
			.webview_version = webview_version,
			.webview_set_icon = webview_set_icon,
			.webview_get_native_handle = webview_get_native_handle,
		};

		return &exports;
	}
}