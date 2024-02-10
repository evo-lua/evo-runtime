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

local window = glfw.create_window(640, 480, "Window Size Test", nil, nil)
assert(window, "Failed to create window")

local contentWidthInPixels = ffi.new("int[1]")
local contentHeightInPixels = ffi.new("int[1]")
glfw.get_window_size(window, contentWidthInPixels, contentHeightInPixels)

local width, height = glfw.getWindowSize(window)

glfw.destroy_window(window)
glfw.terminate()

assert(width == 640, "Expected width to be 640, got " .. width)
assert(height == 480, "Expected height to be 480, got " .. height)

printf(
	"GLFW returned window size: %d x %d (FFI: %d x %d)",
	width,
	height,
	contentWidthInPixels[0],
	contentHeightInPixels[0]
)

-- Should probably create more elaborate scenarios for window management here?
-- Deferred for now since the bindings need a do-over, anyway (reorganize later)
local uv = require("uv")

glfw.maximize_window(window)
uv.sleep(1000)

local GLFW_MAXIMIZED = glfw.find_constant("GLFW_MAXIMIZED")
local maximized = glfw.get_window_attrib(window, GLFW_MAXIMIZED)
assert(maximized == 0, "Window should not be maximized (window hints disallow it)")

glfw.restore_window(window)
uv.sleep(1000)

glfw.hide_window(window)
uv.sleep(1000)

glfw.show_window(window)
uv.sleep(1000)
