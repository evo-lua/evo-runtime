local webview_lua_binding = require("webview_lua_binding")

-- Create a webview window without dev tools
webview_lua_binding.CreateWithoutDevTools()

-- Set window title, size, and navigate to a URL
webview_lua_binding.SetWindowTitle("Webview Test")
webview_lua_binding.SetWindowSize(800, 600)
webview_lua_binding.NavigateToURL("https://example.com")

-- A sample Lua function to be called from JavaScript
local function my_callback_function(_, value)
  print("Callback called from JavaScript with value:", value)
end

-- Bind the Lua function to be called from JavaScript
webview_lua_binding.BindCallbackFunction("myCallback", my_callback_function)

-- Set a script to be executed when the webview loads the page
local onload_script = [[
  document.addEventListener('DOMContentLoaded', function() {
    if (window.myCallback) {
      window.myCallback('Hello from JavaScript');
    }
  });
]]
webview_lua_binding.SetOnLoadScript(onload_script)

-- Run the application and wait for user input to close the window
print("Press enter to close the webview window...")
io.read()

-- Close the webview window and clean up resources
webview_lua_binding.Destroy()
