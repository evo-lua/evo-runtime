typedef enum {
	/// Width and height are default size.
	WEBVIEW_HINT_NONE,
	/// Width and height are minimum bounds.
	WEBVIEW_HINT_MIN,
	/// Width and height are maximum bounds.
	WEBVIEW_HINT_MAX,
	/// Window size can not be changed by a user.
	WEBVIEW_HINT_FIXED
} webview_hint_t;

typedef void* webview_t;

typedef void (*promise_function_t)(const char* seq, const char* req, void* arg);
typedef void (*webview_dispatch_function_t)(webview_t w, void* arg);

typedef struct {
	unsigned int major;
	unsigned int minor;
	unsigned int patch;
} webview_version_t;

typedef struct {
	webview_version_t version;
	char version_number[32];
	char pre_release[48];
	char build_metadata[48];
} webview_version_info_t;