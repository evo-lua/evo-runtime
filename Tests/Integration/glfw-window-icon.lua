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

local window = glfw.bindings.glfw_create_window(640, 480, "GLFW Window Icon Test", nil, nil)
assert(window, "Failed to create window")

local imageFileContents = C_FileSystem.ReadFile(path.join("Tests", "Fixtures", "test-icon.png"))
glfw.setWindowIcon(window, { imageFileContents })

glfw.bindings.glfw_destroy_window(window)
glfw.bindings.glfw_terminate()
