#include <stdio.h>
#include <string.h>

#include "webview_ffi.hpp"
#include "webview.h"

typedef void (*promise_function_t)(const char* seq, const char* req, void* arg);
typedef void (*webview_dispatch_function_t)(webview_t w, void* arg);

struct static_webview_exports_table {
	webview_t (*webview_create)(int debug, void* window);
	void (*webview_destroy)(webview_t w);
	void (*webview_toggle_fullscreen)(webview_t w);
	void (*webview_run)(webview_t w);
	int (*webview_run_once)(webview_t w, int blocking);
	void (*webview_terminate)(webview_t w);
	void (*webview_dispatch)(webview_t w, webview_dispatch_function_t fn, void* arg);
	void (*webview_get_title)(webview_t w, char* buffer, size_t length);
	size_t (*webview_get_title_length)(webview_t w);
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
	bool (*webview_set_icon)(webview_t w, const char* file_path);
};

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

	webview_t webview_create(bool debug, void* wnd) {
		auto w = new WebviewBrowserEngine(debug, wnd);
		if(!w->window()) {
			delete w;
			return nullptr;
		}
		return w;
	}

	void webview_destroy(webview_t w) {
		delete static_cast<WebviewBrowserEngine*>(w);
	}

	void webview_toggle_fullscreen(webview_t w) {
		static_cast<WebviewBrowserEngine*>(w)->toggleFullScreen();
	}

	void webview_run(webview_t w) {
		static_cast<WebviewBrowserEngine*>(w)->run();
	}

	void webview_terminate(webview_t w) {
		static_cast<WebviewBrowserEngine*>(w)->terminate();
	}

	void webview_dispatch(webview_t w, void (*fn)(webview_t, void*),
		void* arg) {
		static_cast<WebviewBrowserEngine*>(w)->dispatch([=]() { fn(w, arg); });
	}

	void* webview_get_window(webview_t w) {
		return static_cast<WebviewBrowserEngine*>(w)->window();
	}

	void webview_set_title(webview_t w, const char* title) {
		static_cast<WebviewBrowserEngine*>(w)->set_title(title);
	}

	void webview_set_size(webview_t w, int width, int height,
		int hints) {
		static_cast<WebviewBrowserEngine*>(w)->set_size(width, height, hints);
	}

	void webview_navigate(webview_t w, const char* url) {
		static_cast<WebviewBrowserEngine*>(w)->navigate(url);
	}

	void webview_set_html(webview_t w, const char* html) {
		static_cast<WebviewBrowserEngine*>(w)->set_html(html);
	}

	void webview_init(webview_t w, const char* js) {
		static_cast<WebviewBrowserEngine*>(w)->init(js);
	}

	void webview_eval(webview_t w, const char* js) {
		static_cast<WebviewBrowserEngine*>(w)->eval(js);
	}

	void webview_bind(webview_t w, const char* name,
		void (*fn)(const char* seq, const char* req,
			void* arg),
		void* arg) {
		static_cast<WebviewBrowserEngine*>(w)->bind(
			name,
			[=](const std::string& seq, const std::string& req, void* arg) {
				fn(seq.c_str(), req.c_str(), arg);
			},
			arg);
	}

	void webview_unbind(webview_t w, const char* name) {
		static_cast<WebviewBrowserEngine*>(w)->unbind(name);
	}

	void webview_return(webview_t w, const char* seq, int status,
		const char* result) {
		static_cast<WebviewBrowserEngine*>(w)->resolve(seq, status, result);
	}

	bool webview_set_icon(webview_t w, const char* file_path) {
		return static_cast<WebviewBrowserEngine*>(w)->setAppIcon(file_path);
	}

	size_t webview_get_title_length(webview_t w) {
		std::string windowTitle = static_cast<WebviewBrowserEngine*>(w)->getWindowTitle();
		return windowTitle.size();
	}

	void webview_get_title(webview_t w, char* buffer, size_t length) {
		std::string windowTitle = static_cast<WebviewBrowserEngine*>(w)->getWindowTitle();

		if(buffer == nullptr) return;

		if(length <= 0) return;

		size_t numCharsToCopy = std::min(windowTitle.size(), length - 1);
		strncpy(buffer, windowTitle.c_str(), numCharsToCopy);
		buffer[numCharsToCopy] = '\0';
	}

	void* getExportsTable() {
		static struct static_webview_exports_table webview_exports_table;

		webview_exports_table.webview_bind = webview_bind;
		webview_exports_table.webview_create = webview_create;
		webview_exports_table.webview_destroy = webview_destroy;
		webview_exports_table.webview_toggle_fullscreen = webview_toggle_fullscreen;
		webview_exports_table.webview_dispatch = webview_dispatch;
		webview_exports_table.webview_eval = webview_eval;
		webview_exports_table.webview_get_title = webview_get_title;
		webview_exports_table.webview_get_title_length = webview_get_title_length;
		webview_exports_table.webview_get_window = webview_get_window;
		webview_exports_table.webview_init = webview_init;
		webview_exports_table.webview_navigate = webview_navigate;
		webview_exports_table.webview_return = webview_return;
		webview_exports_table.webview_run = webview_run;
		webview_exports_table.webview_run_once = webview_run_once;
		webview_exports_table.webview_set_html = webview_set_html;
		webview_exports_table.webview_set_size = webview_set_size;
		webview_exports_table.webview_set_title = webview_set_title;
		webview_exports_table.webview_terminate = webview_terminate;
		webview_exports_table.webview_unbind = webview_unbind;
		webview_exports_table.webview_version = webview_version;
		webview_exports_table.webview_set_icon = webview_set_icon;

		return &webview_exports_table;
	}
}