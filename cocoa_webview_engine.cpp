
//
// ====================================================================
//
// This implementation uses Cocoa WKWebView backend on macOS. It is
// written using ObjC runtime and uses WKWebView class as a browser runtime.
// You should pass "-framework Webkit" flag to the compiler.
//
// ====================================================================
//

#include <CoreGraphics/CoreGraphics.h>
#include <objc/NSObjCRuntime.h>
#include <objc/objc-runtime.h>

namespace webview {
namespace detail {
namespace objc {

// A convenient template function for unconditionally casting the specified
// C-like function into a function that can be called with the given return
// type and arguments. Caller takes full responsibility for ensuring that
// the function call is valid. It is assumed that the function will not
// throw exceptions.
template <typename Result, typename Callable, typename... Args>
Result invoke(Callable callable, Args... args) noexcept {
  return reinterpret_cast<Result (*)(Args...)>(callable)(args...);
}

// Calls objc_msgSend.
template <typename Result, typename... Args>
Result msg_send(Args... args) noexcept {
  return invoke<Result>(objc_msgSend, args...);
}

} // namespace objc

#define NSApplicationDefinedEvent 15
#define NSEventMaskAny ULONG_MAX

enum NSBackingStoreType : NSUInteger { NSBackingStoreBuffered = 2 };

enum NSWindowStyleMask : NSUInteger {
  NSWindowStyleMaskTitled = 1,
  NSWindowStyleMaskClosable = 2,
  NSWindowStyleMaskMiniaturizable = 4,
  NSWindowStyleMaskResizable = 8
};

enum NSApplicationActivationPolicy : NSInteger {
  NSApplicationActivationPolicyRegular = 0
};

enum WKUserScriptInjectionTime : NSInteger {
  WKUserScriptInjectionTimeAtDocumentStart = 0
};

enum NSModalResponse : NSInteger { NSModalResponseOK = 1 };

// Convenient conversion of string literals.
inline id operator"" _cls(const char *s, std::size_t) {
  return (id)objc_getClass(s);
}
inline SEL operator"" _sel(const char *s, std::size_t) {
  return sel_registerName(s);
}
inline id operator"" _str(const char *s, std::size_t) {
  return objc::msg_send<id>("NSString"_cls, "stringWithUTF8String:"_sel, s);
}

static id m_sharedAppDelegate = nullptr; // HACK, also g_...

class cocoa_wkwebview_engine {
public:
  cocoa_wkwebview_engine(bool debug, void *window)
      : m_debug{debug}, m_parent_window{window} {

    auto app = get_shared_application();
	// auto delegate = m_sharedAppDelegate;
    if(m_sharedAppDelegate == nullptr) {
		m_sharedAppDelegate = create_app_delegate();
		// m_sharedAppDelegate = delegate;
		if(m_sharedAppDelegate == nullptr) {
			std::cerr << "Failed to create cocoa app delegate (class-pair allocation failed?)" << std::endl;
			return;
		}
	}

    objc_setAssociatedObject(m_sharedAppDelegate, "webview", (id)this,
                             OBJC_ASSOCIATION_ASSIGN);
    objc::msg_send<void>(app, "setDelegate:"_sel, m_sharedAppDelegate);

    // See comments related to application lifecycle in create_app_delegate().
    if (window) {
      on_application_did_finish_launching(m_sharedAppDelegate, app);
    } else {
      // Start the main run loop so that the app delegate gets the
      // NSApplicationDidFinishLaunchingNotification notification after the run
      // loop has started in order to perform further initialization.
      // We need to return from this constructor so this run loop is only
      // temporary.
      objc::msg_send<void>(app, "run"_sel);
    }
  }
  virtual ~cocoa_wkwebview_engine() = default;
  void *window() { return (void *)m_window; }
  void terminate() {
    auto app = get_shared_application();
    objc::msg_send<void>(app, "terminate:"_sel, nullptr);
  }
  int step(int blocking) {
    id until =
        (blocking
             ? ((id(*)(id, SEL))objc_msgSend)("NSDate"_cls, "distantFuture"_sel)
             : ((id(*)(id, SEL))objc_msgSend)("NSDate"_cls, "distantPast"_sel));
    id app = ((id(*)(id, SEL))objc_msgSend)("NSApplication"_cls,
                                            "sharedApplication"_sel);

    id event = ((id(*)(id, SEL, unsigned long long, id, id, bool))objc_msgSend)(
        app, "nextEventMatchingMask:untilDate:inMode:dequeue:"_sel, ULONG_MAX,
        until, "kCFRunLoopDefaultMode"_str, true);

    if (event) {
      ((id(*)(id, SEL, id))objc_msgSend)(app, "sendEvent:"_sel, event);
    }

    return should_exit;
  }
  void run() {
    auto app = get_shared_application();
    objc::msg_send<void>(app, "run"_sel);
  }
  void dispatch(std::function<void()> f) {
    dispatch_async_f(dispatch_get_main_queue(), new dispatch_fn_t(f),
                     (dispatch_function_t)([](void *arg) {
                       auto f = static_cast<dispatch_fn_t *>(arg);
                       (*f)();
                       delete f;
                     }));
  }
  void set_title(const std::string &title) {
    objc::msg_send<void>(m_window, "setTitle:"_sel,
                         objc::msg_send<id>("NSString"_cls,
                                            "stringWithUTF8String:"_sel,
                                            title.c_str()));
  }
  void set_size(int width, int height, int hints) {
    auto style = static_cast<NSWindowStyleMask>(
        NSWindowStyleMaskTitled | NSWindowStyleMaskClosable |
        NSWindowStyleMaskMiniaturizable);
    if (hints != WEBVIEW_HINT_FIXED) {
      style =
          static_cast<NSWindowStyleMask>(style | NSWindowStyleMaskResizable);
    }
    objc::msg_send<void>(m_window, "setStyleMask:"_sel, style);

    if (hints == WEBVIEW_HINT_MIN) {
      objc::msg_send<void>(m_window, "setContentMinSize:"_sel,
                           CGSizeMake(width, height));
    } else if (hints == WEBVIEW_HINT_MAX) {
      objc::msg_send<void>(m_window, "setContentMaxSize:"_sel,
                           CGSizeMake(width, height));
    } else {
      objc::msg_send<void>(m_window, "setFrame:display:animate:"_sel,
                           CGRectMake(0, 0, width, height), YES, NO);
    }
    objc::msg_send<void>(m_window, "center"_sel);
  }
  void navigate(const std::string &url) {
    auto nsurl = objc::msg_send<id>(
        "NSURL"_cls, "URLWithString:"_sel,
        objc::msg_send<id>("NSString"_cls, "stringWithUTF8String:"_sel,
                           url.c_str()));

    objc::msg_send<void>(
        m_webview, "loadRequest:"_sel,
        objc::msg_send<id>("NSURLRequest"_cls, "requestWithURL:"_sel, nsurl));
  }
  void set_html(const std::string &html) {
    objc::msg_send<void>(m_webview, "loadHTMLString:baseURL:"_sel,
                         objc::msg_send<id>("NSString"_cls,
                                            "stringWithUTF8String:"_sel,
                                            html.c_str()),
                         nullptr);
  }
  void init(const std::string &js) {
    // Equivalent Obj-C:
    // [m_manager addUserScript:[[WKUserScript alloc] initWithSource:[NSString stringWithUTF8String:js.c_str()] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES]]
    objc::msg_send<void>(
        m_manager, "addUserScript:"_sel,
        objc::msg_send<id>(objc::msg_send<id>("WKUserScript"_cls, "alloc"_sel),
                           "initWithSource:injectionTime:forMainFrameOnly:"_sel,
                           objc::msg_send<id>("NSString"_cls,
                                              "stringWithUTF8String:"_sel,
                                              js.c_str()),
                           WKUserScriptInjectionTimeAtDocumentStart, YES));
  }
  void eval(const std::string &js) {
    objc::msg_send<void>(m_webview, "evaluateJavaScript:completionHandler:"_sel,
                         objc::msg_send<id>("NSString"_cls,
                                            "stringWithUTF8String:"_sel,
                                            js.c_str()),
                         nullptr);
  }


private:
	// id m_sharedAppDelegate;
std::string generate_delegate_name() {
    // Generate a random string
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<> dis(0, 25);
    std::stringstream ss;
    for (int i = 0; i < 10; ++i) {
        char c = 'a' + dis(gen);
        ss << c;
    }
    std::string random_string = ss.str();

    // Get the current timestamp
    auto now = std::chrono::system_clock::now();
    auto timestamp = std::chrono::duration_cast<std::chrono::milliseconds>(now.time_since_epoch()).count();

    // Combine the random string and timestamp to create a unique ID
    std::stringstream id_ss;
    id_ss << random_string << "_" << timestamp;
    return id_ss.str();
}

  virtual void on_message(const std::string &msg) = 0;
  id create_app_delegate() {
    // HACK: Should use a single delegate for all browser windows instead
	std::string randomString = generate_delegate_name();
  	// Append the random string to the delegate name
  	std::string delegateName = "RandomizedWebviewAppDelegate";
  	delegateName += randomString;

  	std::cout << "Assigning randomized delegate name: " << delegateName << std::endl;



	// Note: Avoid registering the class name "AppDelegate" as it is the
    // default name in projects created with Xcode, and using the same name
    // causes objc_registerClassPair to crash.
    auto cls = objc_allocateClassPair((Class) "NSResponder"_cls,
                                      delegateName.c_str(), 0);
	if(cls == nullptr) return nullptr;
	std::cout << "Created Cocoa app delegate" << std::endl;
	//assert(cls != nullptr);
    class_addProtocol(cls, objc_getProtocol("NSTouchBarProvider"));
    class_addMethod(cls, "applicationShouldTerminateAfterLastWindowClosed:"_sel,
                    (IMP)(+[](id, SEL, id) -> BOOL { return 1; }), "c@:@");
    // If the library was not initialized with an existing window then the user
    // is likely managing the application lifecycle and we would not get the
    // "applicationDidFinishLaunching:" message and therefore do not need to
    // add this method.
    if (!m_parent_window) {
      class_addMethod(cls, "applicationDidFinishLaunching:"_sel,
                      (IMP)(+[](id self, SEL, id notification) {
                        auto app =
                            objc::msg_send<id>(notification, "object"_sel);
                        auto w = get_associated_webview(self);
                        w->on_application_did_finish_launching(self, app);
                      }),
                      "v@:@");
    }
    objc_registerClassPair(cls);

	m_sharedAppDelegate = objc::msg_send<id>((id)cls, "new"_sel);
	return m_sharedAppDelegate;
  }
  id create_script_message_handler() {
    auto cls = objc_allocateClassPair((Class) "NSResponder"_cls,
                                      "WebkitScriptMessageHandler", 0);
    class_addProtocol(cls, objc_getProtocol("WKScriptMessageHandler"));
    class_addMethod(
        cls, "userContentController:didReceiveScriptMessage:"_sel,
        (IMP)(+[](id self, SEL, id, id msg) {
          auto w = get_associated_webview(self);
          w->on_message(objc::msg_send<const char *>(
              objc::msg_send<id>(msg, "body"_sel), "UTF8String"_sel));
        }),
        "v@:@@");
    objc_registerClassPair(cls);
    auto instance = objc::msg_send<id>((id)cls, "new"_sel);
    objc_setAssociatedObject(instance, "webview", (id)this,
                             OBJC_ASSOCIATION_ASSIGN);
    return instance;
  }
  static id create_webkit_ui_delegate() {
    auto cls =
        objc_allocateClassPair((Class) "NSObject"_cls, "WebkitUIDelegate", 0);
    class_addProtocol(cls, objc_getProtocol("WKUIDelegate"));
    class_addMethod(
        cls,
        "webView:runOpenPanelWithParameters:initiatedByFrame:completionHandler:"_sel,
        (IMP)(+[](id, SEL, id, id parameters, id, id completion_handler) {
          auto allows_multiple_selection =
              objc::msg_send<BOOL>(parameters, "allowsMultipleSelection"_sel);
          auto allows_directories =
              objc::msg_send<BOOL>(parameters, "allowsDirectories"_sel);

          // Show a panel for selecting files.
          auto panel = objc::msg_send<id>("NSOpenPanel"_cls, "openPanel"_sel);
          objc::msg_send<void>(panel, "setCanChooseFiles:"_sel, YES);
          objc::msg_send<void>(panel, "setCanChooseDirectories:"_sel,
                               allows_directories);
          objc::msg_send<void>(panel, "setAllowsMultipleSelection:"_sel,
                               allows_multiple_selection);
          auto modal_response =
              objc::msg_send<NSModalResponse>(panel, "runModal"_sel);

          // Get the URLs for the selected files. If the modal was canceled
          // then we pass null to the completion handler to signify
          // cancellation.
          id urls = modal_response == NSModalResponseOK
                        ? objc::msg_send<id>(panel, "URLs"_sel)
                        : nullptr;

          // Invoke the completion handler block.
          auto sig = objc::msg_send<id>("NSMethodSignature"_cls,
                                        "signatureWithObjCTypes:"_sel, "v@?@");
          auto invocation = objc::msg_send<id>(
              "NSInvocation"_cls, "invocationWithMethodSignature:"_sel, sig);
          objc::msg_send<void>(invocation, "setTarget:"_sel,
                               completion_handler);
          objc::msg_send<void>(invocation, "setArgument:atIndex:"_sel, &urls,
                               1);
          objc::msg_send<void>(invocation, "invoke"_sel);
        }),
        "v@:@@@@");
    objc_registerClassPair(cls);
    return objc::msg_send<id>((id)cls, "new"_sel);
  }
  static id get_shared_application() {
    return objc::msg_send<id>("NSApplication"_cls, "sharedApplication"_sel);
  }
  static cocoa_wkwebview_engine *get_associated_webview(id object) {
    auto w =
        (cocoa_wkwebview_engine *)objc_getAssociatedObject(object, "webview");
    assert(w);
    return w;
  }
  static id get_main_bundle() noexcept {
    return objc::msg_send<id>("NSBundle"_cls, "mainBundle"_sel);
  }
  static bool is_app_bundled() noexcept {
    auto bundle = get_main_bundle();
    if (!bundle) {
      return false;
    }
    auto bundle_path = objc::msg_send<id>(bundle, "bundlePath"_sel);
    auto bundled =
        objc::msg_send<BOOL>(bundle_path, "hasSuffix:"_sel, ".app"_str);
    return !!bundled;
  }
  void on_application_did_finish_launching(id /*delegate*/, id app) {
    // See comments related to application lifecycle in create_app_delegate().
    if (!m_parent_window) {
      // Stop the main run loop so that we can return
      // from the constructor.
      objc::msg_send<void>(app, "stop:"_sel, nullptr);
    }

    // Activate the app if it is not bundled.
    // Bundled apps launched from Finder are activated automatically but
    // otherwise not. Activating the app even when it has been launched from
    // Finder does not seem to be harmful but calling this function is rarely
    // needed as proper activation is normally taken care of for us.
    // Bundled apps have a default activation policy of
    // NSApplicationActivationPolicyRegular while non-bundled apps have a
    // default activation policy of NSApplicationActivationPolicyProhibited.
    if (!is_app_bundled()) {
      // "setActivationPolicy:" must be invoked before
      // "activateIgnoringOtherApps:" for activation to work.
      objc::msg_send<void>(app, "setActivationPolicy:"_sel,
                           NSApplicationActivationPolicyRegular);
      // Activate the app regardless of other active apps.
      // This can be obtrusive so we only do it when necessary.
      objc::msg_send<void>(app, "activateIgnoringOtherApps:"_sel, YES);
    }

    // Main window
    if (!m_parent_window) {
      m_window = objc::msg_send<id>("NSWindow"_cls, "alloc"_sel);
      auto style = NSWindowStyleMaskTitled;
      m_window = objc::msg_send<id>(
          m_window, "initWithContentRect:styleMask:backing:defer:"_sel,
          CGRectMake(0, 0, 0, 0), style, NSBackingStoreBuffered, NO);
    } else {
      m_window = (id)m_parent_window;
    }

auto window_cls =
        objc_allocateClassPair((Class) "NSObject"_cls, "WindowDelegate", 0);
    class_addProtocol(window_cls, objc_getProtocol("NSWindowDelegate"));
    class_replaceMethod(
        window_cls, "windowWillClose:"_sel, (IMP)(+[](id self, SEL, id) {
          auto w = (cocoa_wkwebview_engine *)objc_getAssociatedObject(
              self, "webview");
          assert(w);
          w->should_exit = 1;
        }),
        "v@:@");
    class_replaceMethod(window_cls, "windowShouldClose:"_sel,
                        (IMP)(+[](id, SEL, id) -> BOOL { return 1; }), "B@:@");
    objc_registerClassPair(window_cls);
    auto window_delegate =
        ((id(*)(id, SEL))objc_msgSend)((id)window_cls, "new"_sel);
    objc_setAssociatedObject(window_delegate, "webview", (id)this,
                             OBJC_ASSOCIATION_ASSIGN);
    ((void (*)(id, SEL, id))objc_msgSend)(m_window, "setDelegate:"_sel,
                                          window_delegate);

    // Webview
    auto config = objc::msg_send<id>("WKWebViewConfiguration"_cls, "new"_sel);
    m_manager = objc::msg_send<id>(config, "userContentController"_sel);
    m_webview = objc::msg_send<id>("WKWebView"_cls, "alloc"_sel);

    if (m_debug) {
      // Equivalent Obj-C:
      // [[config preferences] setValue:@YES forKey:@"developerExtrasEnabled"];
      objc::msg_send<id>(
          objc::msg_send<id>(config, "preferences"_sel), "setValue:forKey:"_sel,
          objc::msg_send<id>("NSNumber"_cls, "numberWithBool:"_sel, YES),
          "developerExtrasEnabled"_str);
    }

    // Equivalent Obj-C:
    // [[config preferences] setValue:@YES forKey:@"fullScreenEnabled"];
    objc::msg_send<id>(
        objc::msg_send<id>(config, "preferences"_sel), "setValue:forKey:"_sel,
        objc::msg_send<id>("NSNumber"_cls, "numberWithBool:"_sel, YES),
        "fullScreenEnabled"_str);

    // Equivalent Obj-C:
    // [[config preferences] setValue:@YES forKey:@"javaScriptCanAccessClipboard"];
    objc::msg_send<id>(
        objc::msg_send<id>(config, "preferences"_sel), "setValue:forKey:"_sel,
        objc::msg_send<id>("NSNumber"_cls, "numberWithBool:"_sel, YES),
        "javaScriptCanAccessClipboard"_str);

    // Equivalent Obj-C:
    // [[config preferences] setValue:@YES forKey:@"DOMPasteAllowed"];
    objc::msg_send<id>(
        objc::msg_send<id>(config, "preferences"_sel), "setValue:forKey:"_sel,
        objc::msg_send<id>("NSNumber"_cls, "numberWithBool:"_sel, YES),
        "DOMPasteAllowed"_str);

    auto ui_delegate = create_webkit_ui_delegate();
    objc::msg_send<void>(m_webview, "initWithFrame:configuration:"_sel,
                         CGRectMake(0, 0, 0, 0), config);
    objc::msg_send<void>(m_webview, "setUIDelegate:"_sel, ui_delegate);
    auto script_message_handler = create_script_message_handler();
    objc::msg_send<void>(m_manager, "addScriptMessageHandler:name:"_sel,
                         script_message_handler, "external"_str);

    init(R""(
      window.external = {
        invoke: function(s) {
          window.webkit.messageHandlers.external.postMessage(s);
        },
      };
      )"");
    objc::msg_send<void>(m_window, "setContentView:"_sel, m_webview);
    objc::msg_send<void>(m_window, "makeKeyAndOrderFront:"_sel, nullptr);
  }
  bool m_debug;
  void *m_parent_window;
  int should_exit = 0;
  id m_window;
  id m_webview;
  id m_manager;
};

} // namespace detail

using browser_engine = detail::cocoa_wkwebview_engine;

} // namespace webview