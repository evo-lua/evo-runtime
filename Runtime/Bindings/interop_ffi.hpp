#pragma once

#include <queue>
#include <cstdint>

enum {
	UNKNOWN_ERROR = 0, // Fallback (to catch uninitialized values)
	ERROR_POPPING_EMPTY_QUEUE = 1,
};

typedef enum {
	ERROR_EVENT,
	WINDOW_MOVE_EVENT,
	WINDOW_RESIZE_EVENT,
	WINDOW_CLOSE_EVENT,
	FRAMEBUFFER_RESIZE_EVENT,
	CONTENT_SCALE_EVENT,
	WINDOW_REFRESH_EVENT,
	WINDOW_FOCUS_EVENT,
	WINDOW_ICONIFY_EVENT,
	WINDOW_MAXIMIZE_EVENT,
	MOUSE_BUTTON_EVENT,
	CURSOR_MOVE_EVENT,
	CURSOR_ENTER_EVENT,
	SCROLL_EVENT,
	KEYBOARD_EVENT,
	CHARACTER_INPUT_EVENT
} EventType;

// Stack-allocated payload events
typedef struct server_status_event_t {
	int type;
	bool listen_status;
	int port;
} server_status_event_t;

typedef struct window_move_event_t {
	int type;
	int x;
	int y;
} window_move_event_t;

typedef struct window_resize_event_t {
	int type;
	int width;
	int height;
} window_resize_event_t;

typedef struct window_close_event_t {
	int type;
} window_close_event_t;

typedef struct framebuffer_resize_event_t {
	int type;
	int width;
	int height;
} framebuffer_resize_event_t;

typedef struct content_scale_event_t {
	int type;
	float x;
	float y;
} content_scale_event_t;

typedef struct window_refresh_event_t {
	int type;
} window_refresh_event_t;

typedef struct window_focus_event_t {
	int type;
	int focused;
} window_focus_event_t;

typedef struct window_iconify_event_t {
	int type;
	int iconified;
} window_iconify_event_t;

typedef struct window_maximize_event_t {
	int type;
	int maximized;
} window_maximize_event_t;

typedef struct mouse_button_event_t {
	int type;
	int button;
	int action;
	int mods;
} mouse_button_event_t;

typedef struct cursor_move_event_t {
	int type;
	double x;
	double y;
} cursor_move_event_t;

typedef struct cursor_enter_event_t {
	int type;
	int entered;
} cursor_enter_event_t;

typedef struct scroll_event_t {
	int type;
	double x;
	double y;
} scroll_event_t;

typedef struct key_event_t {
	int type;
	int key;
	int scancode;
	int action;
	int mods;
} key_event_t;

typedef struct character_input_event_t {
	int type;
	unsigned int codepoint;
} character_input_event_t;

typedef struct error_event_t {
	int type;
	int code;
} error_event_t;

typedef union deferred_event_t {
	error_event_t error_details;
	window_move_event_t window_move_details;
	window_resize_event_t window_resize_details;
	window_close_event_t window_close_details;
	framebuffer_resize_event_t framebuffer_resize_details;
	content_scale_event_t content_scale_details;
	window_refresh_event_t window_refresh_details;
	window_focus_event_t window_focus_details;
	window_iconify_event_t window_iconify_details;
	window_maximize_event_t window_maximize_details;
	mouse_button_event_t mouse_button_details;
	cursor_move_event_t cursor_move_details;
	cursor_enter_event_t cursor_enter_details;
	scroll_event_t scroll_details;
	key_event_t key_details;
	character_input_event_t character_input_details;
} deferred_event_t;

// Opaque to LuaJIT (must use C API to access)
typedef std::queue<deferred_event_t>* deferred_event_queue_t;

struct static_interop_exports_table {
	deferred_event_queue_t (*queue_create)(void);
	size_t (*queue_size)(deferred_event_queue_t);
	bool (*queue_push_event)(deferred_event_queue_t, deferred_event_t event);
	deferred_event_t (*queue_pop_event)(deferred_event_queue_t);
	void (*queue_destroy)(deferred_event_queue_t);
};

namespace interop_ffi {
	void* getExportsTable();
}