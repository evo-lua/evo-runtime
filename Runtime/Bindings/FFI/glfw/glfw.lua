local ffi = require("ffi")
local stbi = require("stbi")
local validation = require("validation")

local validateStruct = validation.validateStruct
local validateTable = validation.validateTable

local glfw = {}

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

typedef struct GLFWcursor GLFWcursor;
typedef struct GLFWwindow GLFWwindow;
typedef struct GLFWmonitor GLFWmonitor;
typedef void* deferred_event_queue_t; // Duplicated in the interop aliases (fix later)

typedef void* WGPUSurface;
typedef void* WGPUInstance;
struct static_glfw_exports_table {
	const char* (*glfw_version)(void);
	int (*glfw_find_constant)(const char* name);

	WGPUSurface (*glfw_create_window_wgpu_surface)(WGPUInstance instance, GLFWwindow* window);

	int (*glfw_init)(void);
	void (*glfw_terminate)(void);
	void (*glfw_poll_events)(void);

	GLFWwindow* (*glfw_create_window)(int width, int height, const char* title, GLFWmonitor* monitor, GLFWwindow* share);
	void (*glfw_destroy_window)(GLFWwindow* window);
	int (*glfw_window_should_close)(GLFWwindow* window);
	void (*glfw_window_hint)(int hint, int value);
	void (*glfw_set_window_pos)(GLFWwindow* window, int xpos, int ypos);
	void (*glfw_get_framebuffer_size)(GLFWwindow* window, int* width, int* height);
	void (*glfw_get_window_size)(GLFWwindow* window, int* width, int* height);
	void (*glfw_maximize_window)(GLFWwindow* window);
	void (*glfw_restore_window)(GLFWwindow* window);
	void (*glfw_hide_window)(GLFWwindow* window);
	void (*glfw_show_window)(GLFWwindow* window);
	int (*glfw_get_window_attrib)(GLFWwindow* window, int attrib);
	void (*glfw_set_window_icon)(GLFWwindow* window, int count, const GLFWimage* images);

	void (*glfw_register_events)(GLFWwindow* window, deferred_event_queue_t queue);

	GLFWmonitor* (*glfw_get_primary_monitor)(void);
	GLFWmonitor** (*glfw_get_monitors)(int* count);
	GLFWmonitor* (*glfw_get_window_monitor)(GLFWwindow* window);
	void (*glfw_set_window_monitor)(GLFWwindow* window, GLFWmonitor* monitor, int xpos, int ypos, int width, int height, int refreshRate);
	const GLFWvidmode* (*glfw_get_video_mode)(GLFWmonitor* monitor);

	void (*glfw_get_cursor_pos)(GLFWwindow* window, double* xpos, double* ypos);
	GLFWcursor* (*glfw_create_cursor)(const GLFWimage* image, int xhot, int yhot);
	void (*glfw_destroy_cursor)(GLFWcursor* cursor);
	void (*glfw_set_cursor)(GLFWwindow* window, GLFWcursor* cursor);

	int (*glfw_get_key)(GLFWwindow* window, int key);
	int (*glfw_get_mouse_button)(GLFWwindow* window, int button);
};

]]

function glfw.initialize()
	ffi.cdef(glfw.cdefs)
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
