#pragma once

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>

#include "glfw_constants.hpp"
#include "interop_ffi.hpp"
#include "macros.hpp"

#define GLFW_VERSION_STRING TOSTRING(GLFW_VERSION_MAJOR) "." TOSTRING(GLFW_VERSION_MINOR) "." TOSTRING(GLFW_VERSION_REVISION)

void glfw_set_window_move_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_window_resize_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_window_close_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_framebuffer_resize_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_content_scale_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_window_refresh_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_window_focus_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_window_iconify_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_window_maximize_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_mouse_button_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_cursor_move_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_cursor_enter_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_scroll_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_keyboard_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);
void glfw_set_character_input_callback(GLFWwindow* window, std::queue<deferred_event_t>* queue);

struct static_glfw_exports_table {
	const char* (*glfw_version)(void);
	int (*glfw_find_constant)(const char* name);

	int (*glfw_init)(void);
	void (*glfw_terminate)(void);
	void (*glfw_poll_events)(void);

	GLFWwindow* (*glfw_create_window)(int width, int height, const char* title, GLFWmonitor* monitor, GLFWwindow* share);
	void (*glfw_destroy_window)(GLFWwindow* window);
	int (*glfw_window_should_close)(GLFWwindow* window);

	void (*glfw_register_events)(GLFWwindow* window, deferred_event_queue_t queue);
};

namespace glfw_ffi {
	void* getExportsTable();
}