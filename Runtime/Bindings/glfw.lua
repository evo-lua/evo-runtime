local ffi = require("ffi")

local glfw = {}

glfw.cdefs = [[
	typedef struct GLFWvidmode {
		int width;
		int height;
		int redBits;
		int greenBits;
		int blueBits;
		int refreshRate;
	} GLFWvidmode;

	// Opaque pointer types don't need to be defined as they're only ever handled by glfw internals
	typedef struct GLFWwindow GLFWwindow;
	typedef struct GLFWmonitor GLFWmonitor;
	typedef void* deferred_event_queue_t;

	// These are passed to WebGPU, but the internals aren't exposed
	typedef void* WGPUSurface;
	typedef void* WGPUInstance;

	struct static_glfw_exports_table {
		const char* (*glfw_version)(void);
		int (*glfw_find_constant)(const char* name);

		WGPUSurface (*glfw_get_wgpu_surface)(WGPUInstance instance, GLFWwindow* window);

		int (*glfw_init)(void);
		void (*glfw_terminate)(void);
		void (*glfw_poll_events)(void);

		GLFWwindow* (*glfw_create_window)(int width, int height, const char* title, GLFWmonitor* monitor, GLFWwindow* share);
		void (*glfw_destroy_window)(GLFWwindow* window);
		int (*glfw_window_should_close)(GLFWwindow* window);
		void (*glfw_window_hint)(int hint, int value);

		void (*glfw_register_events)(GLFWwindow* window, deferred_event_queue_t queue);

		GLFWmonitor* (*glfw_get_primary_monitor)(void);
		GLFWmonitor** (*glfw_get_monitors)(int* count);
		GLFWmonitor* (*glfw_get_window_monitor)(GLFWwindow* window);
		void (*glfw_set_window_monitor)(GLFWwindow* window, GLFWmonitor* monitor, int xpos, int ypos, int width, int height, int refreshRate);
		const GLFWvidmode* (*glfw_get_video_mode)(GLFWmonitor* monitor);

	};
]]

function glfw.initialize()
	ffi.cdef(glfw.cdefs)
end

function glfw.version()
	return ffi.string(glfw.bindings.glfw_version())
end

return glfw
