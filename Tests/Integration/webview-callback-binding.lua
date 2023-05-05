local uv = require("uv")

local stop_app = false
local callback_called = false

local function check_stop_condition()
	if stop_app then
		C_WebView.Destroy()
		uv.stop()
	end
end

local stop_check_timer = uv.new_timer()
stop_check_timer:start(0, 100, check_stop_condition)

C_WebView.CreateWithoutDevTools()

C_WebView.SetWindowTitle("Webview Callback Binding Test")
C_WebView.SetWindowSize(800, 600)

-- A sample Lua function to be called from JavaScript
local function my_callback_function(_, value)
	print("Callback called from JavaScript with value:", value)
	assert(value == "Hello from JavaScript", "Unexpected value received in the callback")
	callback_called = true
	stop_app = true
end

-- Wrapper function to handle cdata objects
local function my_callback_wrapper(w, arg)
	local value = ffi.string(arg)
	my_callback_function(w, value)
end

-- Bind the Lua function to be called from JavaScript
C_WebView.BindCallbackFunction("myCallback", my_callback_wrapper)

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

assert(callback_called, "Callback function was not called from JavaScript")
print("Test passed")
