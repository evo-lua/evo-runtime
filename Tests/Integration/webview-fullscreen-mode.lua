local uv = require("uv")

C_WebView.CreateWithDevTools()
C_WebView.SetWindowTitle("Webview FullScreen Test")
C_WebView.SetWindowSize(800, 600)
C_WebView.NavigateToURL("https://evo-lua.github.io/")

local ticker = C_Timer.NewTicker(1000, function()
	C_WebView.ToggleFullscreenMode()
end)

C_Timer.After(5000, function()
	C_Timer.Stop(ticker)
	C_WebView.Destroy()
end)

uv.run()
