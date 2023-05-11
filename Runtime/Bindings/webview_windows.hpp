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
				auto f = reinterpret_cast<dispatch_fn_t*>(msg.lParam);
				(*f)();
				delete f;
			} else if(msg.message == WM_QUIT) {
				return -1;
			}

			return 0;
		}

		void toggleFullScreen() {
			HWND nativeWindowHandle = (HWND)window();
			DWORD windowStyle = GetWindowLong(nativeWindowHandle, GWL_STYLE);

			bool isInWindowedMode = (windowStyle & WS_OVERLAPPEDWINDOW);
			if(isInWindowedMode) WindowedModeToFullscreen(nativeWindowHandle, windowStyle);
			else FullscreenModeToWindowed(nativeWindowHandle, windowStyle);
		}

		bool setAppIcon(const char* iconPath) {
			HWND nativeWindowHandle = (HWND)window();
			HICON icon = (HICON)LoadImage(nullptr, iconPath, IMAGE_ICON, 0, 0, LR_LOADFROMFILE);
			if(icon) {
				SendMessage(nativeWindowHandle, WM_SETICON, ICON_BIG, (LPARAM)icon);
				SendMessage(nativeWindowHandle, WM_SETICON, ICON_SMALL, (LPARAM)icon);
				return true;
			}
			return false;
		}

		std::string getWindowTitle() {
			HWND nativeWindowHandle = (HWND)window();
			int length = GetWindowTextLength(nativeWindowHandle) + 1;

			char* title = new char[length];
			GetWindowText(nativeWindowHandle, title, length);
			std::string windowTitle(title);
			delete[] title;

			return windowTitle;
		}

		bool isFullscreenWindow() {
			HWND nativeWindowHandle = (HWND)window();
			DWORD style = GetWindowLong(nativeWindowHandle, GWL_STYLE);
			return (style & WS_POPUP) && (style & WS_VISIBLE) && !(style & WS_DLGFRAME) && !(style & WS_BORDER);
		}

	private:
		void WindowedModeToFullscreen(HWND nativeWindowHandle, const DWORD& windowStyle) {
			MONITORINFO monitorInfo = { sizeof(monitorInfo) };

			if(!GetWindowPlacement(nativeWindowHandle, &m_windowPlacement)) return;

			if(!GetMonitorInfo(MonitorFromWindow(nativeWindowHandle, MONITOR_DEFAULTTOPRIMARY), &monitorInfo)) return;

			SetWindowLong(nativeWindowHandle, GWL_STYLE, windowStyle & ~WS_OVERLAPPEDWINDOW);
			SetWindowPos(nativeWindowHandle, HWND_TOP,
				monitorInfo.rcMonitor.left, monitorInfo.rcMonitor.top,
				monitorInfo.rcMonitor.right - monitorInfo.rcMonitor.left,
				monitorInfo.rcMonitor.bottom - monitorInfo.rcMonitor.top,
				SWP_NOOWNERZORDER | SWP_FRAMECHANGED);
		}

		void FullscreenModeToWindowed(HWND nativeWindowHandle, const DWORD& windowStyle) {
			SetWindowLong(nativeWindowHandle, GWL_STYLE, windowStyle | WS_OVERLAPPEDWINDOW);
			SetWindowPlacement(nativeWindowHandle, &m_windowPlacement);
			SetWindowPos(nativeWindowHandle, nullptr, 0, 0, 0, 0,
				SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOOWNERZORDER | SWP_FRAMECHANGED);
		}

		WINDOWPLACEMENT m_windowPlacement = { sizeof(m_windowPlacement) };
	};
}