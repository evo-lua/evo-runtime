local ffi = require("ffi")
local uv = require("uv")
local webview = require("webview")

local C_WebView = {
	pollingUpdateTimeInMilliseconds = 16,
	pollingUpdateTimer = uv.new_timer(),
}

local self = C_WebView

function C_WebView.CreateWithoutDevTools()
	if C_WebView.nativeWindow then
		return
	end

	local nativeWindow = webview.bindings.webview_create(false, nil)
	webview.bindings.webview_set_size(nativeWindow, 640, 480, ffi.C.WEBVIEW_HINT_NONE)

	self.pollingUpdateTimer:start(0, self.pollingUpdateTimeInMilliseconds, function()
		webview.bindings.webview_run_once(nativeWindow, false)
	end)

	self.nativeWindow = nativeWindow
end

function C_WebView.CreateWithDevTools()
	if self.nativeWindow then
		return
	end

	local nativeWindow = webview.bindings.webview_create(true, nil)
	webview.bindings.webview_set_size(nativeWindow, 640, 480, ffi.C.WEBVIEW_HINT_NONE)

	self.pollingUpdateTimer:start(0, self.pollingUpdateTimeInMilliseconds, function()
		webview.bindings.webview_run_once(nativeWindow, false)
	end)

	self.nativeWindow = nativeWindow
end

function C_WebView.Destroy()
	if not self.nativeWindow then
		return
	end

	--webview.bindings.webview_destroy(self.nativeWindow)

	self.pollingUpdateTimer:stop()
end

function C_WebView.SetWindowTitle(newWindowTitle)
	webview.bindings.webview_set_title(self.nativeWindow, newWindowTitle)
end

function C_WebView.SetWindowSize(newWidthInPixels, newHeightInPixels)
	webview.bindings.webview_set_size(self.nativeWindow, newWidthInPixels, newHeightInPixels, ffi.C.WEBVIEW_HINT_NONE)
end

function C_WebView.NavigateToURL(url)
	webview.bindings.webview_navigate(self.nativeWindow, url)
end

function C_WebView.SetHTML(htmlString)
	webview.bindings.webview_set_html(self.nativeWindow, htmlString)
end

function C_WebView.SetOnLoadScript(jsCodeString)
	webview.bindings.webview_init(self.nativeWindow, jsCodeString)
end

function C_WebView.EvaluateScript(jsCodeString)
	webview.bindings.webview_eval(self.nativeWindow, jsCodeString)
end

function C_WebView.BindCallbackFunction(assignedGlobalName, callback)
	webview.bindings.webview_bind(self.nativeWindow, assignedGlobalName, callback, nil)
end

function C_WebView.RemoveBinding(assignedGlobalName)
	webview.bindings.webview_unbind(self.nativeWindow, assignedGlobalName)
end

function C_WebView.ResolvePromise(asyncPromiseID, isResultValidJSON, jsonResultString)
	webview.bindings.webview_return(self.nativeWindow, asyncPromiseID, isResultValidJSON, jsonResultString)
end

function C_WebView.SetAppIcon(iconPath)
	webview.bindings.webview_set_icon(self.nativeWindow, iconPath)
end

function C_WebView.ToggleFullscreenMode()
	webview.bindings.webview_toggle_fullscreen(self.nativeWindow)
end

function C_WebView.IsRunning()
	return (self.nativeWindow ~= nil)
end

return C_WebView
