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

local contentWidthInPixels = ffi.new("int[1]")
local contentHeightInPixels = ffi.new("int[1]")
glfw.bindings.glfw_get_window_size(window, contentWidthInPixels, contentHeightInPixels)

local width, height = glfw.getWindowSize(window)

glfw.bindings.glfw_destroy_window(window)
glfw.bindings.glfw_terminate()

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

glfw.bindings.glfw_maximize_window(window)
uv.sleep(1000)

local GLFW_MAXIMIZED = glfw.bindings.glfw_find_constant("GLFW_MAXIMIZED")
local maximized = glfw.bindings.glfw_get_window_attrib(window, GLFW_MAXIMIZED)
assert(maximized == 0, "Window should not be maximized (window hints disallow it)")

glfw.bindings.glfw_restore_window(window)
uv.sleep(1000)

glfw.bindings.glfw_hide_window(window)
uv.sleep(1000)

glfw.bindings.glfw_show_window(window)
uv.sleep(1000)
