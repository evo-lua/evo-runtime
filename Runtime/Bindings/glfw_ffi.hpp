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

struct static_glfw_exports_table {
	const char* (*version)(void);
	int (*find_constant)(const char* name);

	WGPUSurface (*get_wgpu_surface)(WGPUInstance instance, GLFWwindow* window);

	int (*init)(void);
	void (*terminate)(void);
	void (*poll_events)(void);

	GLFWwindow* (*create_window)(int width, int height, const char* title, GLFWmonitor* monitor, GLFWwindow* share);
	void (*destroy_window)(GLFWwindow* window);
	int (*window_should_close)(GLFWwindow* window);
	void (*window_hint)(int hint, int value);
	void (*set_window_pos)(GLFWwindow* window, int xpos, int ypos);
	void (*get_framebuffer_size)(GLFWwindow* window, int* width, int* height);
	void (*get_window_size)(GLFWwindow* window, int* width, int* height);
	void (*maximize_window)(GLFWwindow* window);
	void (*restore_window)(GLFWwindow* window);
	void (*hide_window)(GLFWwindow* window);
	void (*show_window)(GLFWwindow* window);
	int (*get_window_attrib)(GLFWwindow* window, int attrib);
	void (*set_window_icon)(GLFWwindow* window, int count, const GLFWimage* images);

	void (*register_events)(GLFWwindow* window, deferred_event_queue_t queue);

	GLFWmonitor* (*get_primary_monitor)(void);
	GLFWmonitor** (*get_monitors)(int* count);
	GLFWmonitor* (*get_window_monitor)(GLFWwindow* window);
	void (*set_window_monitor)(GLFWwindow* window, GLFWmonitor* monitor, int xpos, int ypos, int width, int height, int refreshRate);
	const GLFWvidmode* (*get_video_mode)(GLFWmonitor* monitor);

	void (*get_cursor_pos)(GLFWwindow* window, double* xpos, double* ypos);
	GLFWcursor* (*create_cursor)(const GLFWimage* image, int xhot, int yhot);
	void (*destroy_cursor)(GLFWcursor* cursor);
	void (*set_cursor)(GLFWwindow* window, GLFWcursor* cursor);

	int (*get_key)(GLFWwindow* window, int key);
	int (*get_mouse_button)(GLFWwindow* window, int button);
};

namespace glfw_ffi {
	void* getExportsTable();
}