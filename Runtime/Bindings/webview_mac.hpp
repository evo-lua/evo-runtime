#pragma once

#include "webview.h"

namespace webview_ffi {

	class WebviewBrowserEngine : public webview::webview {
	public:
		WebviewBrowserEngine(bool withDevToolsEnabled, void* existingNativeWindow);
		int step(int blocking);
		void toggleFullScreen();
		bool setAppIcon(const char* iconPath);

	private:
		int m_shouldExit = 0;
	};
}
