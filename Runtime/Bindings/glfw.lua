local ffi = require("ffi")

local glfw = {}

glfw.cdefs = [[
	// Opaque pointer types don't need to be defined as they're only ever handled by glfw internals
	typedef struct GLFWwindow GLFWwindow;
	typedef struct GLFWmonitor GLFWmonitor;

	struct static_glfw_exports_table {
		const char* (*glfw_version)(void);
		int (*glfw_find_constant)(const char* name);

		int (*glfw_init)(void);
		void (*glfw_terminate)(void);
		void (*glfw_poll_events)(void);

		GLFWwindow* (*glfw_create_window)(int width, int height, const char* title, GLFWmonitor* monitor, GLFWwindow* share);
		void (*glfw_destroy_window)(GLFWwindow* window);
		int (*glfw_window_should_close)(GLFWwindow* window);
	};
]]

function glfw.initialize()
	ffi.cdef(glfw.cdefs)
end

function glfw.version()
	return ffi.string(glfw.bindings.glfw_version())
end

return glfw
