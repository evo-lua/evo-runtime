#include "webview_mac.hpp"

#include "webview_ffi.cpp"

#import <Cocoa/Cocoa.h>

//using webview_ffi;

namespace webview_ffi {

    //class WebviewBrowserEngine : public webview::webview {
    //public:
        WebviewBrowserEngine::WebviewBrowserEngine(bool withDevToolsEnabled, void* existingNativeWindow)
        : webview::webview(withDevToolsEnabled, existingNativeWindow) {
        }
        int WebviewBrowserEngine::step(int blocking) {
            NSDate *until = (blocking
                    ? [NSDate distantFuture]
                    : [NSDate distantPast]);
            NSApplication *app = [NSApplication sharedApplication];

            NSEvent *event = [app nextEventMatchingMask:NSEventMaskAny untilDate:until inMode:NSDefaultRunLoopMode dequeue:YES];

            if (event) {
                [app sendEvent:event];
            }

            return m_shouldExit;
        }

        void WebviewBrowserEngine::toggleFullScreen() {
            NSWindow *nsWindow = (NSWindow *)window();
            [nsWindow toggleFullScreen:nil];
        }

        bool WebviewBrowserEngine::setAppIcon(const char* iconPath) {
            NSString *iconImagePath = [NSString stringWithUTF8String:iconPath];
            NSImage *iconImage = [[NSImage alloc] initWithContentsOfFile:iconImagePath];

            if (!iconImage) return false;

            NSWindow *nsWindow = (NSWindow *)window();
            if (nsWindow) {
                NSURL *fileURL = [NSURL fileURLWithPath:iconImagePath];
                [nsWindow setRepresentedURL:fileURL];
                return true;
            }

            NSApplication *app = [NSApplication sharedApplication];
            if (app) {
                [app setApplicationIconImage:iconImage];
                return true;
            }

            return false;
        }
}