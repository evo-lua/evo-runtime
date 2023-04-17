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

	private:
		int m_shouldExit = 0;
	};

}