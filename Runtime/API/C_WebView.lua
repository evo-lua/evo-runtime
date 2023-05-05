local uv = require("uv")
local webview = require("webview")

local C_WebView = {
	pollingUpdateTimeInMilliseconds = 16,
	pollingUpdateTimer = uv.new_timer(),
}

-- TODO: Bind all these APIs
-- struct static_webview_exports_table {
-- 	void (*webview_toggle_fullscreen)(webview_t w);
-- 	void (*webview_dispatch)(webview_t w, webview_dispatch_function_t fn, void *arg);
-- 	void *(*webview_get_window)(webview_t w);
-- 	void (*webview_set_title)(webview_t w, const char *title);
-- 	void (*webview_set_size)(webview_t w, int width, int height, int hints);
-- 	void (*webview_navigate)(webview_t w, const char *url);
-- 	void (*webview_set_html)(webview_t w, const char *html);
-- 	void (*webview_init)(webview_t w, const char *js);
-- 	void (*webview_eval)(webview_t w, const char *js);
-- 	void (*webview_bind)(webview_t w, const char *name, promise_function_t fn, void *arg);
-- 	void (*webview_unbind)(webview_t w, const char *name);
-- 	void (*webview_return)(webview_t w, const char *seq, int status, const char *result);
-- 	const webview_version_info_t* (*webview_version)(void);
-- 	bool (*webview_set_icon)(webview_t w, const char *file_path);
-- };

local self = C_WebView

function C_WebView.CreateWithoutDevTools()
	if C_WebView.isRunning then
		return
	end

	local activeWindow = webview.bindings.webview_create(false, nil)

	self.pollingUpdateTimer:start(0, self.pollingUpdateTimeInMilliseconds, function()
		webview.bindings.webview_run_once(activeWindow, false)
	end)

	self.isRunning = true
	self.activeWindow = activeWindow
end

function C_WebView.CreateWithDevTools()
	if self.isRunning then
		return
	end

	local activeWindow = webview.bindings.webview_create(true, nil)

	self.pollingUpdateTimer:start(0, self.pollingUpdateTimeInMilliseconds, function()
		webview.bindings.webview_run_once(activeWindow, false)
	end)

	self.isRunning = true
	self.activeWindow = activeWindow
end

function C_WebView.Destroy()
	if not self.isRunning then
		return
	end

	webview.bindings.webview_destroy(self.activeWindow)

	self.pollingUpdateTimer:stop()
	self.isRunning = false
end

function C_WebView.SetWindowTitle(title)
	webview.bindings.webview_set_title(self.activeWindow, title)
end

function C_WebView.SetWindowSize(width, height)
	webview.bindings.webview_set_size(self.activeWindow, width, height, 0)
end

function C_WebView.NavigateToURL(url)
	webview.bindings.webview_navigate(self.activeWindow, url)
end

function C_WebView.SetHTML(html)
	webview.bindings.webview_set_html(self.activeWindow, html)
end

function C_WebView.SetOnLoadScript(js)
	webview.bindings.webview_init(self.activeWindow, js)
end

function C_WebView.EvaluateScript(jsCodeString)
	webview.bindings.webview_eval(self.activeWindow, jsCodeString)
end

local jit = require("jit")

function C_WebView.BindCallbackFunction(assignedGlobalName, callback)
	webview.bindings.webview_bind(self.activeWindow, assignedGlobalName, callback, nil)
end

jit.off(C_WebView.BindCallbackFunction)

function C_WebView.RemoveBinding(assignedGlobalName)
	webview.bindings.webview_unbind(self.activeWindow, assignedGlobalName)
end

function C_WebView.ResolvePromise(asyncPromiseID, isResultValidJSON, jsonResultString)
	webview.bindings.webview_return(self.activeWindow, asyncPromiseID, isResultValidJSON, jsonResultString)
end

function C_WebView.SetAppIcon(iconPath)
	webview.bindings.webview_set_icon(self.activeWindow, iconPath)
end

function C_WebView.ToggleFullscreenMode()
	webview.bindings.webview_toggle_fullscreen(self.activeWindow)
end

function C_WebView.IsRunning()
	return self.isRunning
end

return C_WebView
