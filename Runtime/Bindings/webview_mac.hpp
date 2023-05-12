#include "webview.h"

namespace webview_ffi {

	using webview::detail::objc::msg_send;

	inline id operator"" _cls(const char* s, std::size_t) {
		return (id)objc_getClass(s);
	}
	inline SEL operator"" _sel(const char* s, std::size_t) {
		return sel_registerName(s);
	}
	inline id operator"" _str(const char* s, std::size_t) {
		return msg_send<id>("NSString"_cls, "stringWithUTF8String:"_sel, s);
	}

	class WebviewBrowserEngine : public webview::webview {
	public:
		WebviewBrowserEngine(bool withDevToolsEnabled, void* existingNativeWindow)
			: webview::webview(withDevToolsEnabled, existingNativeWindow) {
			// If window is set, need to call on_application_did_finish_launching (but cannot access because it's private...)?
			// I guess it doesn't matter for now, since child windows don't seem to work in GTK anyway and so aren't supported
			// When this is revisited, also make sure to set m_shouldExit in the window's WillClose handler - for now, it can always return zero
		}
		int step(int blocking) {
			id until = (blocking
					? ((id(*)(id, SEL))objc_msgSend)("NSDate"_cls, "distantFuture"_sel)
					: ((id(*)(id, SEL))objc_msgSend)("NSDate"_cls, "distantPast"_sel));
			id app = ((id(*)(id, SEL))objc_msgSend)("NSApplication"_cls,
				"sharedApplication"_sel);

			id event = ((id(*)(id, SEL, unsigned long long, id, id, bool))objc_msgSend)(
				app, "nextEventMatchingMask:untilDate:inMode:dequeue:"_sel, ULONG_MAX,
				until, "kCFRunLoopDefaultMode"_str, true);

			if(event) {
				((id(*)(id, SEL, id))objc_msgSend)(app, "sendEvent:"_sel, event);
			}

			return m_shouldExit;
		}

		void toggleFullScreen() {
			id nsWindow = (id)window();

			((void (*)(id, SEL, id))objc_msgSend)(nsWindow, sel_registerName("toggleFullScreen:"), nullptr);
		}

		bool setAppIcon(const char* iconPath) {
			id iconImagePath = ((id(*)(id, SEL, const char*))objc_msgSend)("NSString"_cls, "stringWithUTF8String:"_sel, iconPath);
			id iconImage = ((id(*)(id, SEL))objc_msgSend)("NSImage"_cls, "alloc"_sel);
			iconImage = ((id(*)(id, SEL, id))objc_msgSend)(iconImage, "initWithContentsOfFile:"_sel, iconImagePath);

			if(!iconImage) return false;

			// 10.13 and earlier: Set icon in the window's title bar (now deprecated)
			id nsWindow = (id)window();
			if(nsWindow) {
				id fileURL = ((id(*)(id, SEL, id))objc_msgSend)("NSURL"_cls, "fileURLWithPath:"_sel, iconImagePath);
				((void (*)(id, SEL, id))objc_msgSend)(nsWindow, "setRepresentedURL:"_sel, fileURL);
				return true;
			}

			// 10.14 and later: Set icon in the dock
			id app = ((id(*)(id, SEL))objc_msgSend)("NSApplication"_cls, "sharedApplication"_sel);
			if(app) {
				((void (*)(id, SEL, id))objc_msgSend)(app, "setApplicationIconImage:"_sel, iconImage);
				return true;
			}

			return false;
		}

		std::string getWindowTitle() {
		    id title = objc_msgSend(window, sel_registerName("title"));

    		std::string windowTitle = "";

			const char *c_str = (const char *)CFStringGetCStringPtr((CFStringRef)title, kCFStringEncodingUTF8);
    		if (c_str) windowTitle = std::string(c_str);

		    return windowTitle;
		}

		bool isFullscreenWindow() {
			id nsWindowHandle = (id)window();
			id styleMask = objc_msgSend(nsWindowHandle, sel_registerName("styleMask"));
			NSUInteger mask = (NSUInteger)styleMask;

			const NSUInteger NSWindowStyleMaskFullScreen = 4;
			bool isFullscreen = (mask & 4) == NSWindowStyleMaskFullScreen;

			return isFullscreen;
		}

	private:
		int m_shouldExit = 0;
	};
}