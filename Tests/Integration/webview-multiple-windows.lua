local uv = require("uv")

C_WebView.CreateWithoutDevTools()
C_WebView.CreateWithDevTools()
C_WebView.CreateWithoutDevTools()
C_WebView.CreateWithDevTools()

C_WebView.SetWindowTitle("Webview Reusable Window")
C_WebView.SetWindowSize(800, 600)

C_Timer.After(5000, function()
	C_WebView.Destroy()
end)

uv.run()
