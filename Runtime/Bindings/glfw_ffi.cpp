#include "glfw_ffi.hpp"

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

		return &glfw_exports_table;
	}

}