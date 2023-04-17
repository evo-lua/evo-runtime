#include "webview.h"

namespace webview_ffi {

	class WebviewBrowserEngine : public webview::webview {
	public:
		WebviewBrowserEngine(bool withDevToolsEnabled, void* existingNativeWindow)
			: webview::webview(withDevToolsEnabled, existingNativeWindow) {
		}
		int step(int blocking) {
			return gtk_main_iteration_do(blocking);
		}
	};

}