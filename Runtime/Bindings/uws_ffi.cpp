#include "libuwebsockets.h"
#include <stdio.h>
#include <iostream>

static void listen_handler(struct us_listen_socket_t* listen_socket, uws_app_listen_config_t config, void* user_data) {
	std::cout << "listen_handler" << std::endl;
	if(listen_socket) {
		printf("Listening on port wss://localhost:%d\n", config.port);
	} else {
		std::cout << "Failed to load certs or to bind to port" << std::endl;
	}
}

static void open_handler(uws_websocket_t* ws, void* user_data) {
	std::cout << "open_handler" << std::endl;
	/* Open event here, you may access uws_ws_get_user_data(WS) which points to a PerSocketData struct */
}

static void message_handler(uws_websocket_t* ws, const char* message, size_t length, uws_opcode_t opcode, void* user_data) {
	std::cout << "message_handler" << std::endl;
	uws_ws_send(SSL, ws, message, length, opcode);
}

static void close_handler(uws_websocket_t* ws, int code, const char* message, size_t length, void* user_data) {
	std::cout << "close_handler" << std::endl;
	/* You may access uws_ws_get_user_data(ws) here, but sending or
	 * doing any kind of I/O with the socket is not valid. */
}

static void drain_handler(uws_websocket_t* ws, void* user_data) {
	std::cout << "drain_handler" << std::endl;
	/* Check uws_ws_get_buffered_amount(ws) here */
}

static void ping_handler(uws_websocket_t* ws, const char* message, size_t length, void* user_data) {
	std::cout << "ping_handler" << std::endl;
	/* You don't need to handle this one, we automatically respond to pings as per standard */
}

static void pong_handler(uws_websocket_t* ws, const char* message, size_t length, void* user_data) {
	std::cout << "pong_handler" << std::endl;

	/* You don't need to handle this one either */
}

static void upgrade_handler(uws_res_t* response, uws_req_t* request, uws_socket_context_t* context, void* user_data) {
	std::cout << "upgrade_handler" << std::endl;
}

static void subscription_handler(uws_websocket_t* ws, const char* topic_name, size_t topic_name_length, int new_number_of_subscriber, int old_number_of_subscriber, void* user_data) {
	std::cout << "subscription_handler" << std::endl;
}

// uws_method_handler
// void (*uws_method_handler)(uws_res_t *response, uws_req_t *request, void *user_data);

struct static_uws_exports_table {
	uws_listen_handler listen_handler;
	uws_websocket_upgrade_handler upgrade_handler;
	uws_websocket_handler open_handler;
	uws_websocket_message_handler message_handler;
	uws_websocket_handler drain_handler;
	uws_websocket_ping_pong_handler ping_handler;
	uws_websocket_ping_pong_handler pong_handler;
	uws_websocket_close_handler close_handler;
	uws_websocket_subscription_handler subscription_handler;
	uws_app_t* (*uws_create_app)(int ssl, struct us_socket_context_options_t options);
	void (*uws_app_destroy)(int ssl, uws_app_t* app);
	void (*uws_app_get)(int ssl, uws_app_t* app, const char* pattern, uws_method_handler handler, void* user_data);
	void (*uws_app_post)(int ssl, uws_app_t* app, const char* pattern, uws_method_handler handler, void* user_data);
	void (*uws_app_options)(int ssl, uws_app_t* app, const char* pattern, uws_method_handler handler, void* user_data);
	void (*uws_app_delete)(int ssl, uws_app_t* app, const char* pattern, uws_method_handler handler, void* user_data);
	void (*uws_app_patch)(int ssl, uws_app_t* app, const char* pattern, uws_method_handler handler, void* user_data);
	void (*uws_app_put)(int ssl, uws_app_t* app, const char* pattern, uws_method_handler handler, void* user_data);
	void (*uws_app_head)(int ssl, uws_app_t* app, const char* pattern, uws_method_handler handler, void* user_data);
	void (*uws_app_connect)(int ssl, uws_app_t* app, const char* pattern, uws_method_handler handler, void* user_data);
	void (*uws_app_trace)(int ssl, uws_app_t* app, const char* pattern, uws_method_handler handler, void* user_data);
	void (*uws_app_any)(int ssl, uws_app_t* app, const char* pattern, uws_method_handler handler, void* user_data);
	void (*uws_app_run)(int ssl, uws_app_t*);
	void (*uws_app_listen)(int ssl, uws_app_t* app, int port, uws_listen_handler handler, void* user_data);
	void (*uws_app_listen_with_config)(int ssl, uws_app_t* app, uws_app_listen_config_t config, uws_listen_handler handler, void* user_data);
	void (*uws_app_listen_domain)(int ssl, uws_app_t* app, const char* domain, size_t domain_length, uws_listen_domain_handler handler, void* user_data);
	void (*uws_app_listen_domain_with_options)(int ssl, uws_app_t* app, const char* domain, size_t domain_length, int options, uws_listen_domain_handler handler, void* user_data);
	void (*uws_app_domain)(int ssl, uws_app_t* app, const char* server_name, size_t server_name_length);
	bool (*uws_constructor_failed)(int ssl, uws_app_t* app);
	unsigned int (*uws_num_subscribers)(int ssl, uws_app_t* app, const char* topic, size_t topic_length);
	bool (*uws_publish)(int ssl, uws_app_t* app, const char* topic, size_t topic_length, const char* message, size_t message_length, uws_opcode_t opcode, bool compress);
	void* (*uws_get_native_handle)(int ssl, uws_app_t* app);
	void (*uws_remove_server_name)(int ssl, uws_app_t* app, const char* hostname_pattern, size_t hostname_pattern_length);
	void (*uws_add_server_name)(int ssl, uws_app_t* app, const char* hostname_pattern, size_t hostname_pattern_length);
	void (*uws_add_server_name_with_options)(int ssl, uws_app_t* app, const char* hostname_pattern, size_t hostname_pattern_length, struct us_socket_context_options_t options);
	void (*uws_missing_server_name)(int ssl, uws_app_t* app, uws_missing_server_handler handler, void* user_data);
	void (*uws_filter)(int ssl, uws_app_t* app, uws_filter_handler handler, void* user_data);
	void (*uws_ws)(int ssl, uws_app_t* app, const char* pattern, uws_socket_behavior_t behavior, void* user_data);
	void* (*uws_ws_get_user_data)(int ssl, uws_websocket_t* ws);
	void (*uws_ws_close)(int ssl, uws_websocket_t* ws);
	uws_sendstatus_t (*uws_ws_send)(int ssl, uws_websocket_t* ws, const char* message, size_t length, uws_opcode_t opcode);
	uws_sendstatus_t (*uws_ws_send_with_options)(int ssl, uws_websocket_t* ws, const char* message, size_t length, uws_opcode_t opcode, bool compress, bool fin);
	uws_sendstatus_t (*uws_ws_send_fragment)(int ssl, uws_websocket_t* ws, const char* message, size_t length, bool compress);
	uws_sendstatus_t (*uws_ws_send_first_fragment)(int ssl, uws_websocket_t* ws, const char* message, size_t length, bool compress);
	uws_sendstatus_t (*uws_ws_send_first_fragment_with_opcode)(int ssl, uws_websocket_t* ws, const char* message, size_t length, uws_opcode_t opcode, bool compress);
	uws_sendstatus_t (*uws_ws_send_last_fragment)(int ssl, uws_websocket_t* ws, const char* message, size_t length, bool compress);
	void (*uws_ws_end)(int ssl, uws_websocket_t* ws, int code, const char* message, size_t length);
	void (*uws_ws_cork)(int ssl, uws_websocket_t* ws, void (*handler)(void* user_data), void* user_data);
	bool (*uws_ws_subscribe)(int ssl, uws_websocket_t* ws, const char* topic, size_t length);
	bool (*uws_ws_unsubscribe)(int ssl, uws_websocket_t* ws, const char* topic, size_t length);
	bool (*uws_ws_is_subscribed)(int ssl, uws_websocket_t* ws, const char* topic, size_t length);
	void (*uws_ws_iterate_topics)(int ssl, uws_websocket_t* ws, void (*callback)(const char* topic, size_t length, void* user_data), void* user_data);
	bool (*uws_ws_publish)(int ssl, uws_websocket_t* ws, const char* topic, size_t topic_length, const char* message, size_t message_length);
	bool (*uws_ws_publish_with_options)(int ssl, uws_websocket_t* ws, const char* topic, size_t topic_length, const char* message, size_t message_length, uws_opcode_t opcode, bool compress);
	unsigned int (*uws_ws_get_buffered_amount)(int ssl, uws_websocket_t* ws);
	size_t (*uws_ws_get_remote_address)(int ssl, uws_websocket_t* ws, const char** dest);
	size_t (*uws_ws_get_remote_address_as_text)(int ssl, uws_websocket_t* ws, const char** dest);
	void (*uws_res_end)(int ssl, uws_res_t* res, const char* data, size_t length, bool close_connection);
	uws_try_end_result_t (*uws_res_try_end)(int ssl, uws_res_t* res, const char* data, size_t length, uintmax_t total_size, bool close_connection);
	void (*uws_res_cork)(int ssl, uws_res_t* res, void (*callback)(uws_res_t* res, void* user_data), void* user_data);
	void (*uws_res_pause)(int ssl, uws_res_t* res);
	void (*uws_res_resume)(int ssl, uws_res_t* res);
	void (*uws_res_write_continue)(int ssl, uws_res_t* res);
	void (*uws_res_write_status)(int ssl, uws_res_t* res, const char* status, size_t length);
	void (*uws_res_write_header)(int ssl, uws_res_t* res, const char* key, size_t key_length, const char* value, size_t value_length);
	void (*uws_res_write_header_int)(int ssl, uws_res_t* res, const char* key, size_t key_length, uint64_t value);
	void (*uws_res_end_without_body)(int ssl, uws_res_t* res, bool close_connection);
	bool (*uws_res_write)(int ssl, uws_res_t* res, const char* data, size_t length);
	uintmax_t (*uws_res_get_write_offset)(int ssl, uws_res_t* res);
	void (*uws_res_override_write_offset)(int ssl, uws_res_t* res, uintmax_t offset);
	bool (*uws_res_has_responded)(int ssl, uws_res_t* res);
	void (*uws_res_on_writable)(int ssl, uws_res_t* res, bool (*handler)(uws_res_t* res, uintmax_t, void* optional_data), void* user_data);
	void (*uws_res_on_aborted)(int ssl, uws_res_t* res, void (*handler)(uws_res_t* res, void* optional_data), void* optional_data);
	void (*uws_res_on_data)(int ssl, uws_res_t* res, void (*handler)(uws_res_t* res, const char* chunk, size_t chunk_length, bool is_end, void* optional_data), void* optional_data);
	void (*uws_res_upgrade)(int ssl, uws_res_t* res, void* data, const char* sec_web_socket_key, size_t sec_web_socket_key_length, const char* sec_web_socket_protocol, size_t sec_web_socket_protocol_length, const char* sec_web_socket_extensions, size_t sec_web_socket_extensions_length, uws_socket_context_t* ws);
	size_t (*uws_res_get_remote_address)(int ssl, uws_res_t* res, const char** dest);
	size_t (*uws_res_get_remote_address_as_text)(int ssl, uws_res_t* res, const char** dest);
	// size_t (*uws_res_get_proxied_remote_address)(int ssl, uws_res_t* res, const char** dest);
	// size_t (*uws_res_get_proxied_remote_address_as_text)(int ssl, uws_res_t* res, const char** dest);
	void* (*uws_res_get_native_handle)(int ssl, uws_res_t* res);
	bool (*uws_req_is_ancient)(uws_req_t* res);
	bool (*uws_req_get_yield)(uws_req_t* res);
	void (*uws_req_set_yield)(uws_req_t* res, bool yield);
	size_t (*uws_req_get_url)(uws_req_t* res, const char** dest);
	size_t (*uws_req_get_full_url)(uws_req_t* res, const char** dest);
	size_t (*uws_req_get_method)(uws_req_t* res, const char** dest);
	size_t (*uws_req_get_case_sensitive_method)(uws_req_t* res, const char** dest);
	size_t (*uws_req_get_header)(uws_req_t* res, const char* lower_case_header, size_t lower_case_header_length, const char** dest);
	void (*uws_req_for_each_header)(uws_req_t* res, uws_get_headers_server_handler handler, void* user_data);
	size_t (*uws_req_get_query)(uws_req_t* res, const char* key, size_t key_length, const char** dest);
	size_t (*uws_req_get_parameter)(uws_req_t* res, unsigned short index, const char** dest);
	struct us_loop_t* (*uws_get_loop)();
	struct us_loop_t* (*uws_get_loop_with_native)(void* existing_native_loop);
};

namespace uwebsockets_ffi {
	void* getExportsTable() {
		static struct static_uws_exports_table uwebsockets_exports_table;

		uwebsockets_exports_table.listen_handler = listen_handler;
		uwebsockets_exports_table.upgrade_handler = upgrade_handler;
		uwebsockets_exports_table.open_handler = open_handler;
		uwebsockets_exports_table.message_handler = message_handler;
		uwebsockets_exports_table.drain_handler = drain_handler;
		uwebsockets_exports_table.ping_handler = ping_handler;
		uwebsockets_exports_table.pong_handler = pong_handler;
		uwebsockets_exports_table.close_handler = close_handler;
		uwebsockets_exports_table.subscription_handler = subscription_handler;
		// method_handler ?

		// uws_websocket_upgrade_handler upgrade;
		// uws_websocket_handler open;
		// uws_websocket_message_handler message;
		// uws_websocket_handler drain;
		// uws_websocket_ping_pong_handler ping;
		// uws_websocket_ping_pong_handler pong;
		// uws_websocket_close_handler close;
		// uws_websocket_subscription_handler subscription;

		uwebsockets_exports_table.uws_create_app = uws_create_app;
		uwebsockets_exports_table.uws_app_destroy = uws_app_destroy;
		uwebsockets_exports_table.uws_app_get = uws_app_get;
		uwebsockets_exports_table.uws_app_post = uws_app_post;
		uwebsockets_exports_table.uws_app_options = uws_app_options;
		uwebsockets_exports_table.uws_app_delete = uws_app_delete;
		uwebsockets_exports_table.uws_app_patch = uws_app_patch;
		uwebsockets_exports_table.uws_app_put = uws_app_put;
		uwebsockets_exports_table.uws_app_head = uws_app_head;
		uwebsockets_exports_table.uws_app_connect = uws_app_connect;
		uwebsockets_exports_table.uws_app_trace = uws_app_trace;
		uwebsockets_exports_table.uws_app_any = uws_app_any;
		uwebsockets_exports_table.uws_app_run = uws_app_run;
		uwebsockets_exports_table.uws_app_listen = uws_app_listen;
		uwebsockets_exports_table.uws_app_listen_with_config = uws_app_listen_with_config;
		uwebsockets_exports_table.uws_app_listen_domain = uws_app_listen_domain;
		uwebsockets_exports_table.uws_app_listen_domain_with_options = uws_app_listen_domain_with_options;
		uwebsockets_exports_table.uws_app_domain = uws_app_domain;
		uwebsockets_exports_table.uws_constructor_failed = uws_constructor_failed;
		uwebsockets_exports_table.uws_num_subscribers = uws_num_subscribers;
		uwebsockets_exports_table.uws_publish = uws_publish;
		uwebsockets_exports_table.uws_get_native_handle = uws_get_native_handle;
		uwebsockets_exports_table.uws_remove_server_name = uws_remove_server_name;
		uwebsockets_exports_table.uws_add_server_name = uws_add_server_name;
		uwebsockets_exports_table.uws_add_server_name_with_options = uws_add_server_name_with_options;
		uwebsockets_exports_table.uws_missing_server_name = uws_missing_server_name;
		uwebsockets_exports_table.uws_filter = uws_filter;
		uwebsockets_exports_table.uws_ws = uws_ws;
		uwebsockets_exports_table.uws_ws_get_user_data = uws_ws_get_user_data;
		uwebsockets_exports_table.uws_ws_close = uws_ws_close;
		uwebsockets_exports_table.uws_ws_send = uws_ws_send;
		uwebsockets_exports_table.uws_ws_send_with_options = uws_ws_send_with_options;
		uwebsockets_exports_table.uws_ws_send_fragment = uws_ws_send_fragment;
		uwebsockets_exports_table.uws_ws_send_first_fragment = uws_ws_send_first_fragment;
		uwebsockets_exports_table.uws_ws_send_first_fragment_with_opcode = uws_ws_send_first_fragment_with_opcode;
		uwebsockets_exports_table.uws_ws_send_last_fragment = uws_ws_send_last_fragment;
		uwebsockets_exports_table.uws_ws_end = uws_ws_end;
		uwebsockets_exports_table.uws_ws_cork = uws_ws_cork;
		uwebsockets_exports_table.uws_ws_subscribe = uws_ws_subscribe;
		uwebsockets_exports_table.uws_ws_unsubscribe = uws_ws_unsubscribe;
		uwebsockets_exports_table.uws_ws_is_subscribed = uws_ws_is_subscribed;
		uwebsockets_exports_table.uws_ws_iterate_topics = uws_ws_iterate_topics;
		uwebsockets_exports_table.uws_ws_publish = uws_ws_publish;
		uwebsockets_exports_table.uws_ws_publish_with_options = uws_ws_publish_with_options;
		uwebsockets_exports_table.uws_ws_get_buffered_amount = uws_ws_get_buffered_amount;
		uwebsockets_exports_table.uws_ws_get_remote_address = uws_ws_get_remote_address;
		uwebsockets_exports_table.uws_ws_get_remote_address_as_text = uws_ws_get_remote_address_as_text;
		uwebsockets_exports_table.uws_res_end = uws_res_end;
		uwebsockets_exports_table.uws_res_try_end = uws_res_try_end;
		uwebsockets_exports_table.uws_res_cork = uws_res_cork;
		uwebsockets_exports_table.uws_res_pause = uws_res_pause;
		uwebsockets_exports_table.uws_res_resume = uws_res_resume;
		uwebsockets_exports_table.uws_res_write_continue = uws_res_write_continue;
		uwebsockets_exports_table.uws_res_write_status = uws_res_write_status;
		uwebsockets_exports_table.uws_res_write_header = uws_res_write_header;
		uwebsockets_exports_table.uws_res_write_header_int = uws_res_write_header_int;
		uwebsockets_exports_table.uws_res_end_without_body = uws_res_end_without_body;
		uwebsockets_exports_table.uws_res_write = uws_res_write;
		uwebsockets_exports_table.uws_res_get_write_offset = uws_res_get_write_offset;
		uwebsockets_exports_table.uws_res_override_write_offset = uws_res_override_write_offset;
		uwebsockets_exports_table.uws_res_has_responded = uws_res_has_responded;
		uwebsockets_exports_table.uws_res_on_writable = uws_res_on_writable;
		uwebsockets_exports_table.uws_res_on_aborted = uws_res_on_aborted;
		uwebsockets_exports_table.uws_res_on_data = uws_res_on_data;
		uwebsockets_exports_table.uws_res_upgrade = uws_res_upgrade;
		uwebsockets_exports_table.uws_res_get_remote_address = uws_res_get_remote_address;
		uwebsockets_exports_table.uws_res_get_remote_address_as_text = uws_res_get_remote_address_as_text;
		// uwebsockets_exports_table.uws_res_get_proxied_remote_address = uws_res_get_proxied_remote_address;
		// uwebsockets_exports_table.uws_res_get_proxied_remote_address_as_text = uws_res_get_proxied_remote_address_as_text;
		uwebsockets_exports_table.uws_res_get_native_handle = uws_res_get_native_handle;
		uwebsockets_exports_table.uws_req_is_ancient = uws_req_is_ancient;
		uwebsockets_exports_table.uws_req_get_yield = uws_req_get_yield;
		uwebsockets_exports_table.uws_req_set_yield = uws_req_set_yield;
		uwebsockets_exports_table.uws_req_get_url = uws_req_get_url;
		uwebsockets_exports_table.uws_req_get_full_url = uws_req_get_full_url;
		uwebsockets_exports_table.uws_req_get_method = uws_req_get_method;
		uwebsockets_exports_table.uws_req_get_case_sensitive_method = uws_req_get_case_sensitive_method;
		uwebsockets_exports_table.uws_req_get_header = uws_req_get_header;
		uwebsockets_exports_table.uws_req_for_each_header = uws_req_for_each_header;
		uwebsockets_exports_table.uws_req_get_query = uws_req_get_query;
		uwebsockets_exports_table.uws_req_get_parameter = uws_req_get_parameter;
		uwebsockets_exports_table.uws_get_loop = uws_get_loop;
		uwebsockets_exports_table.uws_get_loop_with_native = uws_get_loop_with_native;

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
		.open = [](/*auto *ws*/) { std::cout << "Hello and welcome" << std::endl; },
		.message = []() { std::cout << "Received message: " << std::endl; },
		.close = [](/*auto *ws*/) { std::cout << "We are about to close, sir" << std::endl; }
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