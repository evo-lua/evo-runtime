local ffi = require("ffi")
local glfw = require("glfw")

local isMacOS = (ffi.os == "OSX")
if isMacOS then
	-- CI runner gets stuck after the window closes. See https://github.com/glfw/glfw/issues/1766
	return
end

if not glfw.init() then
	error("Could not initialize GLFW")
end

local GLFW_CLIENT_API = glfw.find_constant("GLFW_CLIENT_API")
local GLFW_NO_API = glfw.find_constant("GLFW_NO_API")
glfw.window_hint(GLFW_CLIENT_API, GLFW_NO_API)

local window = glfw.create_window(640, 480, "GLFW Window", nil, nil)
assert(window, "Failed to create window")

local GLFW_MOUSE_BUTTON_RIGHT = glfw.find_constant("GLFW_MOUSE_BUTTON_RIGHT")
local GLFW_KEY_F25 = glfw.find_constant("GLFW_KEY_F25")
local GLFW_PRESS = glfw.find_constant("GLFW_PRESS")

local isButtonPressed = glfw.get_mouse_button(window, GLFW_MOUSE_BUTTON_RIGHT) == GLFW_PRESS
local isKeyPressed = glfw.get_key(window, GLFW_KEY_F25) == GLFW_PRESS
assert(not isButtonPressed, "Right mouse button should not be pressed")
assert(not isKeyPressed, "F25 key should not be pressed")

glfw.destroy_window(window)
glfw.terminate()
