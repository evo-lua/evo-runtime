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