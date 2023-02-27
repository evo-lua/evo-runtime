#include <iostream>

#include "webview.h"

// namespace C_WebView
// void CreateWebView()

int main(int argc, char *argv[]) {

	std::cout << "Hello WebView" << std::endl;

	webview::webview w(true, nullptr);
	// webview::webview w2(true, nullptr);
	w.set_title("First window");
	w.set_size(640, 480, WEBVIEW_HINT_NONE);
	w.navigate("https://en.m.wikipedia.org/wiki/Main_Page");

	// w2.set_title("Second window");
	// w2.set_size(480, 320, WEBVIEW_HINT_NONE);
	// w2.navigate("https://github.com");

	w.run();

	return 0;
}
