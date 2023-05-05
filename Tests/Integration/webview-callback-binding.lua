C_WebView.CreateWithoutDevTools()

C_WebView.SetWindowTitle("Webview Callback Binding Test")
C_WebView.SetWindowSize(800, 600)

C_WebView.NavigateToURL("https://evo-lua.github.io/")

local function my_callback_function(_, value)
	print("Callback called from JavaScript with value:", value)
end

C_WebView.BindCallbackFunction("myCallback", my_callback_function)

local onload_script = [[
  document.addEventListener('DOMContentLoaded', function() {
    if (window.myCallback) {
      window.myCallback('Hello from JavaScript');
    }
  });
]]
C_WebView.SetOnLoadScript(onload_script)

-- print("Press enter to close the webview window...")
-- io.read()

C_Timer.After(5000, function()
	C_WebView.Destroy()
end)

local uv = require("uv")

uv.run()
