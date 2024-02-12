enum {
	UNKNOWN_ERROR = 0, // Fallback (to catch uninitialized values)
	ERROR_POPPING_EMPTY_QUEUE = 1,
};

typedef enum {
	ERROR_EVENT,
	// GLFW window events
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
	CHARACTER_INPUT_EVENT,
	// RML UI events
	GEOMETRY_RENDER_EVENT,
	GEOMETRY_COMPILE_EVENT,
	COMPILATION_RENDER_EVENT,
	COMPILATION_RELEASE_EVENT,
	SCISSORTEST_STATUS_EVENT,
	SCISSORTEST_REGION_EVENT,
	TEXTURE_LOAD_EVENT,
	TEXTURE_GENERATION_EVENT,
	TEXTURE_RELEASE_EVENT,
	TRANSFORMATION_UPDATE_EVENT,
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

// RML UI events (may contain dynamically-allocated buffers
typedef struct rml_geometry_info_t {
	wgpu_buffer_t vertex_buffer;
	int num_vertices;
	wgpu_buffer_t index_buffer;
	int num_indices;
	wgpu_texture_t texture;
} rml_geometry_info_t;

typedef struct geometry_render_event_t {
	int type;
	rml_geometry_info_t geometry;
	float translate_u;
	float translate_v;
} geometry_render_event_t;

typedef struct geometry_compile_event_t {
	int type;
	rml_geometry_info_t compiled_geometry;
} geometry_compile_event_t;

typedef struct compilation_render_event_t {
	int type;
	rml_geometry_info_t compiled_geometry;
	float translate_u;
	float translate_v;
} compilation_render_event_t;

typedef struct compilation_release_event_t {
	int type;
	rml_geometry_info_t compiled_geometry;
} compilation_release_event_t;

typedef struct scissortest_status_event_t {
	int type;
	bool enabled_flag;
} scissortest_status_event_t;

typedef struct scissortest_region_event_t {
	int type;
	int u;
	int v;
	int width;
	int height;
} scissortest_region_event_t;

typedef struct texture_load_event_t {
	int type;
	wgpu_texture_t texture;
} texture_load_event_t;

typedef struct texture_generation_event_t {
	int type;
	wgpu_texture_t texture;
} texture_generation_event_t;

typedef struct texture_release_event_t {
	int type;
	wgpu_texture_t texture;
} texture_release_event_t;

typedef struct transformation_update_event_t {
	int type;
	float x1;
	float x2;
	float x3;
	float x4;
	float y1;
	float y2;
	float y3;
	float y4;
	float z1;
	float z2;
	float z3;
	float z4;
	float w1;
	float w2;
	float w3;
	float w4;
} transformation_update_event_t;

typedef union deferred_event_t {
	error_event_t error_details;
	// GLFW
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
	// RML
	geometry_render_event_t geometry_render_details;
	geometry_compile_event_t geometry_compilation_details;
	compilation_render_event_t compilation_render_details;
	compilation_release_event_t compilation_release_details;
	scissortest_status_event_t scissortest_status_details;
	scissortest_region_event_t scissortest_region_details;
	texture_load_event_t texture_load_details;
	texture_generation_event_t texture_generation_details;
	texture_release_event_t texture_release_details;
	transformation_update_event_t transformation_update_details;
} deferred_event_t;

struct static_interop_exports_table {
	deferred_event_queue_t (*queue_create)(void);
	size_t (*queue_size)(deferred_event_queue_t);
	bool (*queue_push_event)(deferred_event_queue_t, deferred_event_t event);
	deferred_event_t (*queue_pop_event)(deferred_event_queue_t);
	void (*queue_destroy)(deferred_event_queue_t);
};