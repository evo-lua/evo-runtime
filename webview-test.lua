-- Create a webview window without dev tools
C_WebView.CreateWithoutDevTools()

-- Set window title, size, and navigate to a URL
C_WebView.SetWindowTitle("Webview Test")
C_WebView.SetWindowSize(800, 600)
C_WebView.NavigateToURL("https://evo-lua.github.io/")

local ffi = require("ffi")

-- A sample Lua function to be called from JavaScript
local function my_callback_function(_, value)
	print("Callback called from JavaScript with value:", ffi.string(value))
end

-- Bind the Lua function to be called from JavaScript
C_WebView.BindCallbackFunction("myCallback", my_callback_function)

-- Set a script to be executed when the webview loads the page
local onload_script = [[
  document.addEventListener('DOMContentLoaded', function() {
    if (window.myCallback) {
      window.myCallback('Hello from JavaScript');
    }
  });
]]
C_WebView.SetOnLoadScript(onload_script)

-- Run the application and wait for user input to close the window
-- print("Press enter to close the webview window...")
-- io.read()

-- Close the webview window and clean up resources
-- C_WebView.Destroy()
