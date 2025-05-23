#include "glfw_ffi.hpp"
#include "interop_ffi.hpp"

#include <glfw3webgpu.h>

#include <string>

const char* glfw_version() {
	return GLFW_VERSION_STRING;
}

int glfw_find_constant(const char* name) {
	std::string key(name);

	auto iterator = glfw_constants.find(key);
	bool found = iterator != glfw_constants.end();

	if(found) return iterator->second;
	else return 0xdead; // I'm guessing this exact value won't ever be used by any GLFW defines...
}

void glfw_register_events(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	if(!window || !queue) return;

	// Can't capture the queue via lambdas because GLFW expects a C function pointer
	glfwSetWindowUserPointer(window, queue);

	glfw_set_window_move_callback(window, queue);
	glfw_set_window_resize_callback(window, queue);
	glfw_set_window_close_callback(window, queue);
	glfw_set_framebuffer_resize_callback(window, queue);
	glfw_set_content_scale_callback(window, queue);
	glfw_set_window_refresh_callback(window, queue);
	glfw_set_window_focus_callback(window, queue);
	glfw_set_window_iconify_callback(window, queue);
	glfw_set_window_maximize_callback(window, queue);
	glfw_set_mouse_button_callback(window, queue);
	glfw_set_cursor_move_callback(window, queue);
	glfw_set_cursor_enter_callback(window, queue);
	glfw_set_scroll_callback(window, queue);
	glfw_set_keyboard_callback(window, queue);
	glfw_set_character_input_callback(window, queue);
}

void glfw_set_window_move_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetWindowPosCallback(window, [](GLFWwindow* window, int screenX, int screenY) {
		window_move_event_t payload { .type = WINDOW_MOVE_EVENT, .x = screenX, .y = screenY };
		deferred_event_t event { .window_move_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_window_resize_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetWindowSizeCallback(window, [](GLFWwindow* window, int width, int height) {
		window_resize_event_t payload { .type = WINDOW_RESIZE_EVENT, .width = width, .height = height };
		deferred_event_t event { .window_resize_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_window_close_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetWindowCloseCallback(window, [](GLFWwindow* window) {
		window_close_event_t payload { .type = WINDOW_CLOSE_EVENT };
		deferred_event_t event { .window_close_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_framebuffer_resize_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetFramebufferSizeCallback(window, [](GLFWwindow* window, int width, int height) {
		framebuffer_resize_event_t payload { .type = FRAMEBUFFER_RESIZE_EVENT, .width = width, .height = height };
		deferred_event_t event { .framebuffer_resize_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_content_scale_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetWindowContentScaleCallback(window, [](GLFWwindow* window, float xScale, float yScale) {
		content_scale_event_t payload { .type = CONTENT_SCALE_EVENT, .x = xScale, .y = yScale };
		deferred_event_t event { .content_scale_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_window_refresh_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetWindowRefreshCallback(window, [](GLFWwindow* window) {
		window_refresh_event_t payload { .type = WINDOW_REFRESH_EVENT };
		deferred_event_t event { .window_refresh_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_window_focus_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetWindowFocusCallback(window, [](GLFWwindow* window, int focused) {
		window_focus_event_t payload { .type = WINDOW_FOCUS_EVENT, .focused = focused };
		deferred_event_t event { .window_focus_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_window_iconify_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetWindowIconifyCallback(window, [](GLFWwindow* window, int iconified) {
		window_iconify_event_t payload { .type = WINDOW_ICONIFY_EVENT, .iconified = iconified };
		deferred_event_t event { .window_iconify_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_window_maximize_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetWindowMaximizeCallback(window, [](GLFWwindow* window, int maximized) {
		window_maximize_event_t payload { .type = WINDOW_MAXIMIZE_EVENT, .maximized = maximized };
		deferred_event_t event { .window_maximize_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_mouse_button_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetMouseButtonCallback(window, [](GLFWwindow* window, int button, int action, int mods) {
		mouse_button_event_t payload { .type = MOUSE_BUTTON_EVENT, .button = button, .action = action, .mods = mods };
		deferred_event_t event { .mouse_button_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_cursor_move_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetCursorPosCallback(window, [](GLFWwindow* window, double screenX, double screenY) {
		cursor_move_event_t payload { .type = CURSOR_MOVE_EVENT, .x = screenX, .y = screenY };
		deferred_event_t event { .cursor_move_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_cursor_enter_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetCursorEnterCallback(window, [](GLFWwindow* window, int entered) {
		cursor_enter_event_t payload { .type = CURSOR_ENTER_EVENT, .entered = entered };
		deferred_event_t event { .cursor_enter_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_scroll_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetScrollCallback(window, [](GLFWwindow* window, double xoffset, double yoffset) {
		scroll_event_t payload { .type = SCROLL_EVENT, .x = xoffset, .y = yoffset };
		deferred_event_t event { .scroll_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_keyboard_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetKeyCallback(window, [](GLFWwindow* window, int key, int scancode, int action, int mods) {
		key_event_t payload { .type = KEYBOARD_EVENT, .key = key, .scancode = scancode, .action = action, .mods = mods };
		deferred_event_t event { .key_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

void glfw_set_character_input_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue) {
	glfwSetCharCallback(window, [](GLFWwindow* window, unsigned int codepoint) {
		character_input_event_t payload { .type = CHARACTER_INPUT_EVENT, .codepoint = codepoint };
		deferred_event_t event { .character_input_details = payload };

		auto userdata = glfwGetWindowUserPointer(window);
		auto queue = static_cast<std::queue<deferred_event_t>*>(userdata);

		queue->push(event);
	});
}

namespace glfw_ffi {

	void* getExportsTable() {
		static struct static_glfw_exports_table exports;

		exports.glfw_version = glfw_version;
		exports.glfw_find_constant = glfw_find_constant;

		exports.glfw_create_window_wgpu_surface = glfwCreateWindowWGPUSurface;

		exports.glfw_init = glfwInit;
		exports.glfw_terminate = glfwTerminate;
		exports.glfw_poll_events = glfwPollEvents;

		exports.glfw_create_window = glfwCreateWindow;
		exports.glfw_destroy_window = glfwDestroyWindow;
		exports.glfw_window_should_close = glfwWindowShouldClose;
		exports.glfw_window_hint = glfwWindowHint;
		exports.glfw_set_window_pos = glfwSetWindowPos;
		exports.glfw_get_framebuffer_size = glfwGetFramebufferSize;
		exports.glfw_get_window_size = glfwGetWindowSize;
		exports.glfw_maximize_window = glfwMaximizeWindow;
		exports.glfw_restore_window = glfwRestoreWindow;
		exports.glfw_hide_window = glfwHideWindow;
		exports.glfw_show_window = glfwShowWindow;
		exports.glfw_get_window_attrib = glfwGetWindowAttrib;
		exports.glfw_set_window_icon = glfwSetWindowIcon;

		exports.glfw_register_events = glfw_register_events;

		exports.glfw_get_primary_monitor = glfwGetPrimaryMonitor;
		exports.glfw_get_monitors = glfwGetMonitors;
		exports.glfw_get_window_monitor = glfwGetWindowMonitor;
		exports.glfw_set_window_monitor = glfwSetWindowMonitor;
		exports.glfw_get_video_mode = glfwGetVideoMode;

		exports.glfw_get_cursor_pos = glfwGetCursorPos;
		exports.glfw_create_cursor = glfwCreateCursor;
		exports.glfw_set_cursor = glfwSetCursor;
		exports.glfw_destroy_cursor = glfwDestroyCursor;

		exports.glfw_get_key = glfwGetKey;
		exports.glfw_get_mouse_button = glfwGetMouseButton;

		return &exports;
	}

}