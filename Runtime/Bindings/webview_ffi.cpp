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
	int (*webview_run_once)(webview_t w, bool blocking);
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

// TODO remove

// Adapted from https://github.com/webview/webview/pull/735/files
#ifdef __unix__
// #include "webview_unix.hpp"
// TODO only works for one webview window?
int step(webview_t w, int blocking) { return gtk_main_iteration_do(blocking); }
#endif

#ifdef __APPLE__

#define NSApplicationDefinedEvent 15
#define NSBackingStoreBuffered 2
#define NSEventMaskAny ULONG_MAX

// int step(int blocking) {
//   NSDate *untilDate = nil;
//   if (blocking) {
//     // If blocking, wait until a future date (distant future).
//     untilDate = [NSDate distantFuture];
//   } else {
//     // If non-blocking, wait until a past date (distant past).
//     untilDate = [NSDate distantPast];
//   }

//   NSApplication *app = [NSApplication sharedApplication];

//   // Retrieve the next event from the event queue that matches any event type,
//   // is scheduled to occur before the specified date, and dequeues the event.
//   NSEvent *event = [app nextEventMatchingMask:NSEventMaskAny
//                                      untilDate:untilDate
//                                         inMode:NSDefaultRunLoopMode
//                                        dequeue:YES];

//   // Send the event to the application's event handling system for processing.
//   if (event) {
//     [app sendEvent:event];
//   }

//   // Return a value to indicate whether the message loop should exit.
//   return should_exit;
// }

// TODO this will not work without changes to the cocoa_webview_engine in webview.h

int step(webview_t w, int blocking) {

	return webview_step(w, blocking);
	//throw "Nonblocking WebView updates aren't implemented for Mac OS :()";
	// id until =
	//     (blocking
	//          ? ((id(*)(id, SEL))objc_msgSend)("NSDate"_cls, "distantFuture"_sel)
	//          : ((id(*)(id, SEL))objc_msgSend)("NSDate"_cls, "distantPast"_sel));
	// id app = ((id(*)(id, SEL))objc_msgSend)("NSApplication"_cls,
	//                                         "sharedApplication"_sel);

	// id event = ((id(*)(id, SEL, unsigned long long, id, id, bool))objc_msgSend)(
	//     app, "nextEventMatchingMask:untilDate:inMode:dequeue:"_sel, ULONG_MAX,
	//     until, "kCFRunLoopDefaultMode"_str, true);

	// if (event) {
	//   ((id(*)(id, SEL, id))objc_msgSend)(app, "sendEvent:"_sel, event);
	// }

	// return should_exit;
}

// #include "webview_mac.hpp"
#endif

// TODO integrate with set_fullscreen branch (crossplatform plumbing exists)
#ifdef __WIN32__
// #include "webview_windows.hpp"
int step(webview_t w, int blocking) {
	MSG msg;

	if(blocking) {
		if(GetMessage(&msg, nullptr, 0, 0) < 0)
			return 0;
	} else {
		if(!PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE))
			return 0;
	}

	if(msg.hwnd) {
		TranslateMessage(&msg);
		DispatchMessage(&msg);
		return 0;
	}

	if(msg.message == WM_APP) {
		auto f = (webview::dispatch_fn_t*)(msg.lParam);
		(*f)();
		delete f;
	} else if(msg.message == WM_QUIT) {
		return 1; // true
	}

	return 0;
}
#endif

#include <iostream>
int webview_run_once(webview_t w, bool blocking) {
	std::cout << "webview_run_once (blocking = " << blocking << ")" << std::endl;
	return webview_step(w, blocking);
	// static_cast<webview::webview *>(w)->
}

static bool hasCreatedWebview = false;
void* webview_create_singleton(int withDevToolsEnabled, void* existingNativeWindow) {
	// if(! hasCreatedWebview) {
		std::cout << "Creating WebView (singleton mode for now)" << std::endl;
		// hasCreatedWebview = true; // Cannot create more or the library will SEGFAULT on OSX
		return webview_create(withDevToolsEnabled, existingNativeWindow);
	// } else {
		std::cerr << "Failed to create native WebView (only one instance can currently be created)" << std::endl;
		// return nullptr;
	// }
}

namespace webview_ffi {
	// TODO

	void* getExportsTable() {
		static struct static_webview_exports_table webview_exports_table;

		webview_exports_table.webview_bind = webview_bind;
		webview_exports_table.webview_create = webview_create_singleton;
		webview_exports_table.webview_destroy = webview_destroy;
		webview_exports_table.webview_dispatch = webview_dispatch;
		webview_exports_table.webview_eval = webview_eval;
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

		return &webview_exports_table;
	}
}