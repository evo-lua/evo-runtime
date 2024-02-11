local bindings = require("bindings")
local ffi = require("ffi")
local stbi = require("stbi")
local validation = require("validation")

local validateStruct = validation.validateStruct
local validateTable = validation.validateTable

local glfw = {}

function glfw.initialize()
	ffi.cdef(bindings.glfw.cdefs)
end

function glfw.version()
	return ffi.string(glfw.bindings.glfw_version())
end

function glfw.getWindowSize(window)
	local width = ffi.new("int[1]")
	local height = ffi.new("int[1]")
	glfw.bindings.glfw_get_window_size(window, width, height)
	return width[0], height[0]
end

function glfw.getCursorPosition(window)
	local cursorPositionX = ffi.new("double[1]")
	local cursorPositionY = ffi.new("double[1]")
	glfw.bindings.glfw_get_cursor_pos(window, cursorPositionX, cursorPositionY)
	return cursorPositionX[0], cursorPositionY[0]
end

-- Only keep one cursor alive to avoid leaking memory
local currentCursor
local function swapAllocatedCursor(newCursor)
	if not currentCursor then
		return
	end

	glfw.bindings.glfw_destroy_cursor(currentCursor)
	currentCursor = newCursor
end

local function createCursorFromImage(window, imageFileContents, hotspotX, hotspotY)
	local imageInfo = ffi.new("stbi_image_t")
	local result = stbi.bindings.stbi_load_rgba(imageFileContents, #imageFileContents, imageInfo)
	assert(result ~= nil, "Failed to load cursor image data (stbi_load_rgba returned NULL)")

	stbi.bindings.stbi_load_rgba(imageFileContents, #imageFileContents, imageInfo)
	local cursorImage = ffi.new("GLFWimage[1]", {
		{
			width = imageInfo.width,
			height = imageInfo.height,
			pixels = imageInfo.data,
		},
	})
	local cursor = glfw.bindings.glfw_create_cursor(cursorImage, hotspotX, hotspotY)
	assert(cursor, "Failed to create cursor from image data (glfw_create_cursor returned NULL)")

	glfw.bindings.glfw_set_cursor(window, cursor)

	-- The image data should've been copied by GLFW
	stbi.bindings.stbi_image_free(imageInfo)
end

function glfw.setCursorImage(window, imageFileContents, hotspotX, hotspotY)
	hotspotX = hotspotX or 0
	hotspotY = hotspotY or 0

	local cursor
	if imageFileContents then
		cursor = createCursorFromImage(window, imageFileContents, hotspotX, hotspotY)
	end

	swapAllocatedCursor(cursor)

	return cursor
end

function glfw.setWindowIcon(window, icons)
	validateStruct(window, "nativeWindowHandle")

	if not icons then
		glfw.bindings.glfw_set_window_icon(window, 0, nil)
		return
	end
	validateTable(icons, "icons")

	local glfwImages = ffi.new("GLFWimage[?]", #icons)
	local stbImages = {}
	for index, icon in ipairs(icons) do
		local imageInfo = ffi.new("stbi_image_t")
		local result = stbi.bindings.stbi_load_rgba(icon, #icon, imageInfo)
		assert(result ~= nil, "Failed to load icon image data (stbi_load_rgba returned NULL)")

		local cIndex = index - 1
		local glfwImage = ffi.new("GLFWimage", {
			width = imageInfo.width,
			height = imageInfo.height,
			pixels = imageInfo.data,
		})
		glfwImages[cIndex] = glfwImage -- GLFW wants this format
		stbImages[index] = imageInfo -- Need to free the pixel array later
	end
	glfw.bindings.glfw_set_window_icon(window, #icons, glfwImages)

	for index, _ in ipairs(icons) do
		local stbImage = stbImages[index]
		stbi.bindings.stbi_image_free(stbImage)
	end
end

return glfw
