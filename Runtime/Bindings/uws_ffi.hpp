#pragma once

#include "uws.hpp"

#include <string>

typedef enum {
	None = 0,
	Sent = 1,
	Ended = 2,
	SentAndEnded = 3
} HttpSendStatus;

typedef void* uws_webserver_t;

typedef struct uws_webserver_event_t {
	int type;
	char clientID[37];
	char* payload;
	size_t payload_size;
} uws_webserver_event_t;

typedef struct static_uws_exports_table {

	// uws
	const char* (*uws_version)(void);
	const char* (*uws_event_name)(uws_webserver_event_t event);

	// WebServer
	uws_webserver_t (*uws_webserver_create)(void);
	void (*uws_webserver_listen)(uws_webserver_t server, int port);
	bool (*uws_webserver_has_event)(uws_webserver_t server);
	void (*uws_webserver_get_next_event)(uws_webserver_t server, uws_webserver_event_t* event);
	void (*uws_webserver_stop)(uws_webserver_t server);
	void (*uws_webserver_delete)(uws_webserver_t server);

	void (*uws_webserver_set_echo_mode)(uws_webserver_t server, bool enabled_flag);
	void (*uws_webserver_dump_config)(uws_webserver_t server);
	void (*uws_webserver_dump_events)(uws_webserver_t server);

	size_t (*uws_webserver_get_client_count)(uws_webserver_t server);
	size_t (*uws_webserver_get_event_count)(uws_webserver_t server);
	size_t (*uws_webserver_payload_size)(uws_webserver_t server);
	size_t (*uws_webserver_purge_connections)(uws_webserver_t server);

	int (*uws_webserver_broadcast_text)(uws_webserver_t server, const char* text, size_t length);
	int (*uws_webserver_broadcast_binary)(uws_webserver_t server, const char* binary, size_t length);
	int (*uws_webserver_broadcast_compressed)(uws_webserver_t server, const char* compressed, size_t length);
	int (*uws_webserver_send_text)(uws_webserver_t server, const char* text, size_t length, const char* client_id);
	int (*uws_webserver_send_binary)(uws_webserver_t server, const char* binary, size_t length, const char* client_id);
	int (*uws_webserver_send_compressed)(uws_webserver_t server, const char* compressed, size_t length, const char* client_id);

	HttpSendStatus (*uws_webserver_response_write)(uws_webserver_t server, const char* request_id, const char* data, size_t length);
	HttpSendStatus (*uws_webserver_response_end)(uws_webserver_t server, const char* request_id, const char* data, size_t length);
	HttpSendStatus (*uws_webserver_response_try_end)(uws_webserver_t server, const char* request_id, const char* data, size_t length);

	bool (*uws_webserver_has_request)(uws_webserver_t server, const char* request_id);
	bool (*uws_webserver_request_method)(uws_webserver_t server, const char* request_id, char* data, size_t length);
	bool (*uws_webserver_request_url)(uws_webserver_t server, const char* request_id, char* data, size_t length);
	bool (*uws_webserver_request_query)(uws_webserver_t server, const char* request_id, char* data, size_t length);
	bool (*uws_webserver_request_endpoint)(uws_webserver_t server, const char* request_id, char* data, size_t length);
	bool (*uws_webserver_request_serialized_headers)(uws_webserver_t server, const char* request_id, char* data, size_t length);
	bool (*uws_webserver_request_header_value)(uws_webserver_t server, const char* request_id, char* header, char* data, size_t length);

	void (*uws_webserver_add_websocket_route)(uws_webserver_t server, const char* route);
	void (*uws_webserver_add_get_route)(uws_webserver_t server, const char* route);
	void (*uws_webserver_add_post_route)(uws_webserver_t server, const char* route);
	void (*uws_webserver_add_options_route)(uws_webserver_t server, const char* route);
	void (*uws_webserver_add_delete_route)(uws_webserver_t server, const char* route);
	void (*uws_webserver_add_patch_route)(uws_webserver_t server, const char* route);
	void (*uws_webserver_add_put_route)(uws_webserver_t server, const char* route);
	void (*uws_webserver_add_head_route)(uws_webserver_t server, const char* route);
	void (*uws_webserver_add_any_route)(uws_webserver_t server, const char* route);

} static_uws_exports_table;

namespace uws_ffi {
	void* getExportsTable();
	void assignEventLoop(void* existing_native_loop);
	std::string opCodeToString(uWS::OpCode opCode);
	std::string compressOptionsToString(uWS::CompressOptions compressOption);
}