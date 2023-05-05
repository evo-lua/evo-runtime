local ffi = require("ffi")
local jit = require("jit")
local uv = require("uv")

jit.off()

-- Create a webview window without dev tools
C_WebView.CreateWithoutDevTools()

-- Set window title, size, and navigate to a URL
C_WebView.SetWindowTitle("Webview Test")
C_WebView.SetWindowSize(800, 600)
C_WebView.NavigateToURL("https://github.com")

-- A sample Lua function to be called from JavaScript
local function my_callback_function(_, value)
	print("Callback called from JavaScript with value:", ffi.string(value))
end

-- Store the callback function in the global environment to prevent garbage collection
_G.my_callback_function = my_callback_function

-- Bind the Lua function to be called from JavaScript
C_WebView.BindCallbackFunction("myCallback", _G.my_callback_function)

-- Set a script to be executed when the webview loads the page
local onload_script = [[
  document.addEventListener('DOMContentLoaded', function() {
    if (window.myCallback) {
      window.myCallback('Hello from JavaScript');
    }
  });
]]
C_WebView.SetOnLoadScript(onload_script)

uv.run()

-- Remove the callback function from the global environment when no longer needed
_G.my_callback_function = nil
