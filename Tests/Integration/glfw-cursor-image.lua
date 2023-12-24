local ffi = require("ffi")
local glfw = require("glfw")
local stbi = require("stbi")

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

local imageInfo = ffi.new("stbi_image_t")
local imageFileContents = C_FileSystem.ReadFile(path.join("Tests", "Fixtures", "test-icon.png"))
local result = stbi.bindings.stbi_load_rgba(imageFileContents, #imageFileContents, imageInfo)
assert(result ~= nil, "Failed to load cursor image")

stbi.bindings.stbi_load_rgba(imageFileContents, #imageFileContents, imageInfo)
local cursorImage = ffi.new("GLFWimage[1]", {
	{
		width = imageInfo.width,
		height = imageInfo.height,
		pixels = imageInfo.data,
	},
})
local cursor = glfw.bindings.glfw_create_cursor(cursorImage, 0, 0)
assert(cursor, "Failed to create cursor")
glfw.bindings.glfw_set_cursor(window, cursor)
glfw.setCursorImage(window, imageFileContents)

glfw.bindings.glfw_set_cursor(window, nil)
glfw.setCursorImage(window, nil)

glfw.bindings.glfw_destroy_cursor(cursor)

glfw.bindings.glfw_destroy_window(window)
glfw.bindings.glfw_terminate()
