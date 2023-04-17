#include "webview.h"

using webview::dispatch_fn_t;

namespace webview_ffi {

	class WebviewBrowserEngine : public webview::webview {
	public:
		WebviewBrowserEngine(bool withDevToolsEnabled, void* existingNativeWindow)
			: webview::webview(withDevToolsEnabled, existingNativeWindow) {
		}
		int step(int blocking) {
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
				auto f = (dispatch_fn_t*)(msg.lParam);
				(*f)();
				delete f;
			} else if(msg.message == WM_QUIT) {
				return -1;
			}

			return 0;
		}
	};

}