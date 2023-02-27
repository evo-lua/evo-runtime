local webview = require("webview")

-- webview::webview w(true, nullptr);
-- // webview::webview w2(true, nullptr);
-- w.set_title("First window");
-- w.set_size(640, 480, WEBVIEW_HINT_NONE);
-- w.navigate("https://en.m.wikipedia.org/wiki/Main_Page");

local WEBVIEW_HINT_NONE = 0
local wv = webview.bindings.webview_create(true, nil)
webview.bindings.webview_set_size(wv, 640, 480, WEBVIEW_HINT_NONE);
webview.bindings.webview_set_title(wv, "First window")
webview.bindings.webview_navigate(wv, "https://en.m.wikipedia.org/wiki/Main_Page");

webview.bindings.webview_run(wv)