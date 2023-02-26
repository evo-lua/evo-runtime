local webview = require("webview")

local wv = webview.bindings.webview_create(true, nil)
webview.bindings.webview_run(wv)