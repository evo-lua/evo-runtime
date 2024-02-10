local ffi = require("ffi")
local isMacOS = (ffi.os == "OSX")
if isMacOS then
	local transform = require("transform")
	-- Stopgap measure until I have figured out a way to make them work together
	print(transform.yellow("Skipping GLFW test due to unresolved incompatibilities with WebViews"))
	return
end

local glfw = require("glfw")
local interop = require("interop")

glfw.init()

local primaryMonitor = glfw.get_primary_monitor()
local window = glfw.create_window(800, 600, "GLFW Test", primaryMonitor, nil)
local eventQueue = interop.bindings.queue_create()
glfw.register_events(window, eventQueue)

local ticker = C_Timer.NewTicker(250, function()
	glfw.poll_events()

	local numEvents = tonumber(interop.bindings.queue_size(eventQueue))
	print("glfw_poll_events", numEvents)
end)

C_Timer.After(2500, function()
	print("glfw_terminate")
	glfw.destroy_window(window)
	glfw.terminate()
	interop.bindings.queue_destroy(eventQueue)
	ticker:stop()
end)
