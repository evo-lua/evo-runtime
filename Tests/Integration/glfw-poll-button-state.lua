local ffi = require("ffi")
local glfw = require("glfw")

local isWindows = (ffi.os == "Windows")
if not isWindows then
	return
end

if not glfw.bindings.glfw_init() then
	error("Could not initialize GLFW")
end

local GLFW_CLIENT_API = glfw.bindings.glfw_find_constant("GLFW_CLIENT_API")
local GLFW_NO_API = glfw.bindings.glfw_find_constant("GLFW_NO_API")
glfw.bindings.glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)

local window = glfw.bindings.glfw_create_window(640, 480, "GLFW Window", nil, nil)
assert(window, "Failed to create window")

local GLFW_MOUSE_BUTTON_RIGHT = glfw.bindings.glfw_find_constant("GLFW_MOUSE_BUTTON_RIGHT")
local GLFW_KEY_F25 = glfw.bindings.glfw_find_constant("GLFW_KEY_F25")
local GLFW_PRESS = glfw.bindings.glfw_find_constant("GLFW_PRESS")

local isButtonPressed = glfw.bindings.glfw_get_mouse_button(window, GLFW_MOUSE_BUTTON_RIGHT) == GLFW_PRESS
local isKeyPressed = glfw.bindings.glfw_get_key(window, GLFW_KEY_F25) == GLFW_PRESS
assert(not isButtonPressed, "Right mouse button should not be pressed")
assert(not isKeyPressed, "F25 key should not be pressed")

glfw.bindings.glfw_destroy_window(window)
glfw.bindings.glfw_terminate()
