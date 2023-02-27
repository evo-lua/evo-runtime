local webview = require("webview")

local view = webview.bindings.webview_create(true, nil)
print("First WebView created")

local view = webview.bindings.webview_create(true, nil)
print("Second WebView created")

local childview = webview.bindings.webview_create(true, webview.bindings.webview_get_window(view))
print("Child created")