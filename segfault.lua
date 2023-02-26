local webview = require("webview")
print("WTF")

local view = webview.bindings.webview_create(true, nil)
print("WTF")

webview.bindings.webview_run_once(view, false)
				--webview.bindings.webview_terminate(view)
print("WTF")

webview.bindings.webview_destroy(view)
print("WTF")

local view = webview.bindings.webview_create(true, nil)
print("WTF")

webview.bindings.webview_run_once(view, false)
				--webview.bindings.webview_terminate(view)
print("WTF")

webview.bindings.webview_destroy(view)


--
print("WTF")
