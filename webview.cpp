#include <iostream>

#include "webview.h"

// namespace C_WebView
// void CreateWebView()

int main(int argc, char *argv[]) {

	std::cout << "Hello WebView" << std::endl;

  webview::webview w(true, nullptr);
  webview::webview w2(true, nullptr);
  w.set_title("Minimal example");
  w.set_size(480, 320, WEBVIEW_HINT_NONE);
  w.navigate("https://en.m.wikipedia.org/wiki/Main_Page");
  w.run();

	return 0;
}
