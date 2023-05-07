local uv = require("uv")

C_WebView.CreateWithoutDevTools()
C_WebView.SetWindowTitle("Webview AppIcon Test")
C_WebView.SetWindowSize(800, 600)

local ffi = require("ffi")

if ffi.os == "Windows" then
	C_WebView.SetAppIcon("Tests/Fixtures/test-icon.ico")
elseif ffi.os == "OSX" then
	C_WebView.SetAppIcon("Tests/Fixtures/test-icon.icns")
else
	C_WebView.SetAppIcon("Tests/Fixtures/test-icon.png")
end

C_Timer.After(5000, function()
	C_WebView.Destroy()
end)

uv.run()
