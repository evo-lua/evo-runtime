local bindings = require("bindings")
local ffi = require("ffi")
local stbi = require("stbi")
local validation = require("validation")

local validateStruct = validation.validateStruct
local validateTable = validation.validateTable

local glfw = {
	exports = {
		"create_cursor",
		"create_window",
		"destroy_cursor",
		"destroy_window",
		"find_constant",
		"get_cursor_pos",
		"get_framebuffer_size",
		"get_key",
		"get_monitors",
		"get_mouse_button",
		"get_primary_monitor",
		"get_video_mode",
		"get_wgpu_surface",
		"get_window_attrib",
		"get_window_monitor",
		"get_window_size",
		"hide_window",
		"init",
		"maximize_window",
		"poll_events",
		"register_events",
		"restore_window",
		"set_cursor",
		"set_window_icon",
		"set_window_monitor",
		"set_window_pos",
		"show_window",
		"terminate",
		"version",
		"window_hint",
		"window_should_close",
	},
}

glfw.cdefs = [[
	typedef struct GLFWimage {
		int width;
		int height;
		unsigned char* pixels;
	} GLFWimage;

	typedef struct GLFWvidmode {
		int width;
		int height;
		int redBits;
		int greenBits;
		int blueBits;
		int refreshRate;
	} GLFWvidmode;

	// Opaque pointer types don't need to be defined as they're only ever handled by glfw internals
	typedef struct GLFWcursor GLFWcursor;
	typedef struct GLFWwindow GLFWwindow;
	typedef struct GLFWmonitor GLFWmonitor;
	typedef void* deferred_event_queue_t;

	// These are passed to WebGPU, but the internals aren't exposed
	typedef void* WGPUSurface;
	typedef void* WGPUInstance;

	struct static_glfw_exports_table {
		const char* (*version)(void);
		int (*find_constant)(const char* name);

		WGPUSurface (*get_wgpu_surface)(WGPUInstance instance, GLFWwindow* window);

		int (*init)(void);
		void (*terminate)(void);
		void (*poll_events)(void);

		GLFWwindow* (*create_window)(int width, int height, const char* title, GLFWmonitor* monitor, GLFWwindow* share);
		void (*destroy_window)(GLFWwindow* window);
		int (*window_should_close)(GLFWwindow* window);
		void (*window_hint)(int hint, int value);
		void (*set_window_pos)(GLFWwindow* window, int xpos, int ypos);
		void (*get_framebuffer_size)(GLFWwindow* window, int* width, int* height);
		void (*get_window_size)(GLFWwindow* window, int* width, int* height);
		void (*maximize_window)(GLFWwindow* window);
		void (*restore_window)(GLFWwindow* window);
		void (*hide_window)(GLFWwindow* window);
		void (*show_window)(GLFWwindow* window);
		int (*get_window_attrib)(GLFWwindow* window, int attrib);
		void (*set_window_icon)(GLFWwindow* window, int count, const GLFWimage* images);

		void (*register_events)(GLFWwindow* window, deferred_event_queue_t queue);

		GLFWmonitor* (*get_primary_monitor)(void);
		GLFWmonitor** (*get_monitors)(int* count);
		GLFWmonitor* (*get_window_monitor)(GLFWwindow* window);
		void (*set_window_monitor)(GLFWwindow* window, GLFWmonitor* monitor, int xpos, int ypos, int width, int height, int refreshRate);
		const GLFWvidmode* (*get_video_mode)(GLFWmonitor* monitor);

		void (*get_cursor_pos)(GLFWwindow* window, double* xpos, double* ypos);
		GLFWcursor* (*create_cursor)(const GLFWimage* image, int xhot, int yhot);
		void (*destroy_cursor)(GLFWcursor* cursor);
		void (*set_cursor)(GLFWwindow* window, GLFWcursor* cursor);

		int (*get_key)(GLFWwindow* window, int key);
		int (*get_mouse_button)(GLFWwindow* window, int button);
	};
]]

function glfw.initialize()
	ffi.cdef(glfw.cdefs)
end

function glfw.version()
	return ffi.string(bindings.glfw.version())
end

function glfw.getWindowSize(window)
	local width = ffi.new("int[1]")
	local height = ffi.new("int[1]")
	glfw.get_window_size(window, width, height)
	return width[0], height[0]
end

function glfw.getCursorPosition(window)
	local cursorPositionX = ffi.new("double[1]")
	local cursorPositionY = ffi.new("double[1]")
	glfw.get_cursor_pos(window, cursorPositionX, cursorPositionY)
	return cursorPositionX[0], cursorPositionY[0]
end

-- Only keep one cursor alive to avoid leaking memory
local currentCursor
local function swapAllocatedCursor(newCursor)
	if not currentCursor then
		return
	end

	glfw.destroy_cursor(currentCursor)
	currentCursor = newCursor
end

local function createCursorFromImage(window, imageFileContents, hotspotX, hotspotY)
	local imageInfo = ffi.new("stbi_image_t")
	local result = stbi.load_rgba(imageFileContents, #imageFileContents, imageInfo)
	assert(result ~= nil, "Failed to load cursor image data (stbi_load_rgba returned NULL)")

	stbi.load_rgba(imageFileContents, #imageFileContents, imageInfo)
	local cursorImage = ffi.new("GLFWimage[1]", {
		{
			width = imageInfo.width,
			height = imageInfo.height,
			pixels = imageInfo.data,
		},
	})
	local cursor = glfw.create_cursor(cursorImage, hotspotX, hotspotY)
	assert(cursor, "Failed to create cursor from image data (glfw_create_cursor returned NULL)")

	glfw.set_cursor(window, cursor)

	-- The image data should've been copied by GLFW
	stbi.image_free(imageInfo)
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
		glfw.set_window_icon(window, 0, nil)
		return
	end
	validateTable(icons, "icons")

	local glfwImages = ffi.new("GLFWimage[?]", #icons)
	local stbImages = {}
	for index, icon in ipairs(icons) do
		local imageInfo = ffi.new("stbi_image_t")
		local result = stbi.load_rgba(icon, #icon, imageInfo)
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
	glfw.set_window_icon(window, #icons, glfwImages)

	for index, _ in ipairs(icons) do
		local stbImage = stbImages[index]
		stbi.image_free(stbImage)
	end
end

return glfw
