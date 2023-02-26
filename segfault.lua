local webview = require("webview")
print(0)

local view = webview.bindings.webview_create(true, nil)
print(1)

--webview.bindings.webview_run_once(view, false)
				--webview.bindings.webview_terminate(view)
print(2)

--webview.bindings.webview_destroy(view)
print(3)

local view = webview.bindings.webview_create(true, nil)
print(4)

webview.bindings.webview_run_once(view, false)
				--webview.bindings.webview_terminate(view)
print(5)
webview.bindings.webview_destroy(view)
print(6)
