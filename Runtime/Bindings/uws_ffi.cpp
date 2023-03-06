#include "libuwebsockets.h"
#include <stdio.h>
#include <iostream>

struct static_uws_exports_table {
// 	webview_t (*webview_create)(int debug, void* window);
// 	void (*webview_destroy)(webview_t w);
// 	void (*webview_run)(webview_t w);
// 	int (*webview_run_once)(webview_t w, int blocking);
// 	void (*webview_terminate)(webview_t w);
// 	void (*webview_dispatch)(webview_t w, webview_dispatch_function_t fn, void* arg);
// 	void* (*webview_get_window)(webview_t w);
// 	void (*webview_set_title)(webview_t w, const char* title);
// 	void (*webview_set_size)(webview_t w, int width, int height, int hints);
// 	void (*webview_navigate)(webview_t w, const char* url);
// 	void (*webview_set_html)(webview_t w, const char* html);
// 	void (*webview_init)(webview_t w, const char* js);
// 	void (*webview_eval)(webview_t w, const char* js);
// 	void (*webview_bind)(webview_t w, const char* name, promise_function_t fn, void* arg);
// 	void (*webview_unbind)(webview_t w, const char* name);
// 	void (*webview_return)(webview_t w, const char* seq, int status, const char* result);
// 	const webview_version_info_t* (*webview_version)(void);
};

namespace uwebsockets_ffi {
void* getExportsTable() {
		static struct static_uws_exports_table uwebsockets_exports_table;

		// uwebsockets_exports_table.webview_bind = webview_bind;
		// uwebsockets_exports_table.webview_create = webview_create;
		// uwebsockets_exports_table.webview_destroy = webview_destroy;
		// uwebsockets_exports_table.webview_dispatch = webview_dispatch;
		// uwebsockets_exports_table.webview_eval = webview_eval;
		// uwebsockets_exports_table.webview_get_window = webview_get_window;
		// uwebsockets_exports_table.webview_init = webview_init;
		// uwebsockets_exports_table.webview_navigate = webview_navigate;
		// uwebsockets_exports_table.webview_return = webview_return;
		// uwebsockets_exports_table.webview_run = webview_run;
		// uwebsockets_exports_table.webview_run_once = webview_run_once;
		// uwebsockets_exports_table.webview_set_html = webview_set_html;
		// uwebsockets_exports_table.webview_set_size = webview_set_size;
		// uwebsockets_exports_table.webview_set_title = webview_set_title;
		// uwebsockets_exports_table.webview_terminate = webview_terminate;
		// uwebsockets_exports_table.webview_unbind = webview_unbind;
		// uwebsockets_exports_table.webview_version = webview_version;

		return &uwebsockets_exports_table;
	}
}

// TODO
// #define SSL 0
constexpr int SSL = 0;

/* This is a simple WebSocket "sync" upgrade example.
 * You may compile it with "WITH_OPENSSL=1 make" or with "make" */

/* ws->getUserData returns one of these */
struct PerSocketData {
	/* Fill with user data */
};

void listen_handler(struct us_listen_socket_t* listen_socket, uws_app_listen_config_t config, void* user_data) {
	std::cout << "listen_handler" << std::endl;
	if(listen_socket) {
		printf("Listening on port wss://localhost:%d\n", config.port);
	} else {
        std::cout << "Failed to load certs or to bind to port" << std::endl;
    }
}

void open_handler(uws_websocket_t* ws, void* user_data) {
	std::cout << "open_handler" << std::endl;
	/* Open event here, you may access uws_ws_get_user_data(WS) which points to a PerSocketData struct */
}

void message_handler(uws_websocket_t* ws, const char* message, size_t length, uws_opcode_t opcode, void* user_data) {
	std::cout << "message_handler" << std::endl;
	uws_ws_send(SSL, ws, message, length, opcode);
}

void close_handler(uws_websocket_t* ws, int code, const char* message, size_t length, void* user_data) {

	std::cout << "close_handler" << std::endl;
	/* You may access uws_ws_get_user_data(ws) here, but sending or
     * doing any kind of I/O with the socket is not valid. */
}

void drain_handler(uws_websocket_t* ws, void* user_data) {
	std::cout << "drain_handler" << std::endl;
	/* Check uws_ws_get_buffered_amount(ws) here */
}

void ping_handler(uws_websocket_t* ws, const char* message, size_t length, void* user_data) {
	std::cout << "ping_handler" << std::endl;
	/* You don't need to handle this one, we automatically respond to pings as per standard */
}

void pong_handler(uws_websocket_t* ws, const char* message, size_t length, void* user_data) {
	std::cout << "pong_handler" << std::endl;

	/* You don't need to handle this one either */
}

// HTTP client
#include "ClientApp.h"

void http_client_test() {

uWS::WebSocketClientBehavior b = {
        .open = [](/*auto *ws*/) {
            std::cout << "Hello and welcome" << std::endl;
        },
        .message = []() {
            std::cout << "Received message: " << std::endl;
        },
        .close = [](/*auto *ws*/) {
            std::cout << "We are about to close, sir" << std::endl;
        }
    };

	    uWS::ClientApp app(std::move(b));

    app.connect("ws://localhost:9001");

    app.run();
}

int uws_test(void* loop) {

// TBD set once in main?
	uws_get_loop_with_native(loop);
	// http_client_test();

	// return 0;

	uws_app_t* app = uws_create_app(SSL, (struct us_socket_context_options_t) { /* There are example certificates in uWebSockets.js repo */
											 .key_file_name = "../misc/key.pem",
											 .cert_file_name = "../misc/cert.pem",
											 .passphrase = "1234" });

	uws_ws(SSL, app, "/*", (uws_socket_behavior_t) {
							   .compression = uws_compress_options_t::SHARED_COMPRESSOR,
							   .maxPayloadLength = 16 * 1024,
							   .idleTimeout = 12,
							   .maxBackpressure = 1 * 1024 * 1024,
							   .upgrade = NULL,
							   .open = open_handler,
							   .message = message_handler,
							   .drain = drain_handler,
							   .ping = ping_handler,
							   .pong = pong_handler,
							   .close = close_handler,
						   },
		nullptr);

	uws_app_listen(SSL, app, 9001, listen_handler, NULL);

	uws_app_run(SSL, app);

	return 0;
}




// HTTPS client
// HTTP server
// HTTPS server
// WS client
// WSS client
// WS server
// WSS server
// HTTP2
// HTTP3/QUIC