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