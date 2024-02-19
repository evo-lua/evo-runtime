#pragma once

#define GLFW_INCLUDE_NONE
#include <GLFW/glfw3.h>
#include <webgpu.h>

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

#include "glfw_exports.h"

namespace glfw_ffi {
	void* getExportsTable();
}