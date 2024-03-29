local ffi = require("ffi")
local glfw = require("glfw")

local isMacOS = (ffi.os == "OSX")
if isMacOS then
	-- CI runner gets stuck after the window closes. See https://github.com/glfw/glfw/issues/1766
	return
end

if not glfw.bindings.glfw_init() then
	error("Could not initialize GLFW")
end

local GLFW_CLIENT_API = glfw.bindings.glfw_find_constant("GLFW_CLIENT_API")
local GLFW_NO_API = glfw.bindings.glfw_find_constant("GLFW_NO_API")
glfw.bindings.glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)

local window = glfw.bindings.glfw_create_window(640, 480, "Window Size Test", nil, nil)
assert(window, "Failed to create window")

local cursorPositionX = ffi.new("double[1]")
local cursorPositionY = ffi.new("double[1]")
glfw.bindings.glfw_get_cursor_pos(window, cursorPositionX, cursorPositionY)

local x, y = glfw.getCursorPosition(window)

glfw.bindings.glfw_destroy_window(window)
glfw.bindings.glfw_terminate()

assert(type(x) == "number", "Expected x to be a number, got " .. type(x))
assert(type(y) == "number", "Expected y to be a number, got " .. type(y))

printf("GLFW returned cursor position: %d x %d (FFI: %d x %d)", x, y, cursorPositionX[0], cursorPositionY[0])
