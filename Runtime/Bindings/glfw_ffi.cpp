#include "glfw_ffi.hpp"
#include "interop_ffi.hpp"

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

namespace glfw_ffi {

	void* getExportsTable() {
		static struct static_glfw_exports_table glfw_exports_table;

		glfw_exports_table.glfw_version = glfw_version;
		glfw_exports_table.glfw_find_constant = glfw_find_constant;

		glfw_exports_table.glfw_init = glfwInit;
		glfw_exports_table.glfw_terminate = glfwTerminate;
		glfw_exports_table.glfw_poll_events = glfwPollEvents;

		glfw_exports_table.glfw_create_window = glfwCreateWindow;
		glfw_exports_table.glfw_destroy_window = glfwDestroyWindow;
		glfw_exports_table.glfw_window_should_close = glfwWindowShouldClose;

		glfw_exports_table.glfw_register_events = glfw_register_events;

		return &glfw_exports_table;
	}

}