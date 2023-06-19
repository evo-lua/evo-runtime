local ffi = require("ffi")
local isMacOS = (ffi.os == "OSX")
if isMacOS then
	local transform = require("transform")
	-- Stopgap measure until I have figured out a way to make them work together
	print(transform.yellow("Skipping GLFW test due to unresolved incompatibilities with WebViews"))
	return
end

local glfw = require("glfw")

glfw.bindings.glfw_init()

local window = glfw.bindings.glfw_create_window(800, 600, "GLFW Test", nil, nil)

local ticker = C_Timer.NewTicker(250, function()
	print("glfw_poll_events")
	glfw.bindings.glfw_poll_events()
end)

C_Timer.After(2500, function()
	print("glfw_terminate")
	glfw.bindings.glfw_destroy_window(window)
	glfw.bindings.glfw_terminate()
	ticker:stop()
end)
