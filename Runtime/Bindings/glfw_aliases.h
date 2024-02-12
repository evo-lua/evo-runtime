typedef struct GLFWimage {
	int width;
	int height;
	unsigned char* pixels;
} GLFWimage;

typedef struct GLFWvidmode {
	int width;
	int height;
	int redBits;
	int greenBits;
	int blueBits;
	int refreshRate;
} GLFWvidmode;

typedef struct GLFWcursor GLFWcursor;
typedef struct GLFWwindow GLFWwindow;
typedef struct GLFWmonitor GLFWmonitor;
typedef void* deferred_event_queue_t; // Duplicated in the interop aliases (fix later)

typedef void* WGPUSurface;
typedef void* WGPUInstance;