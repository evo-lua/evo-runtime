#include "uws.hpp"
#include "uws_ffi.hpp"

#include "WebServer.hpp"

#include <unordered_map>

const char* uws_version() {
	return UWS_VERSION;
}

uws_webserver_t uws_webserver_create() {
	return static_cast<void*>(new WebServer());
}

void uws_webserver_listen(uws_webserver_t server, int port) {
	static_cast<WebServer*>(server)->StartListening(port);
}

bool uws_webserver_has_event(const uws_webserver_t server) {
	return static_cast<WebServer*>(server)->HasDeferredEvents();
}

void uws_webserver_get_next_event(uws_webserver_t server, uws_webserver_event_t* event) {
	static_cast<WebServer*>(server)->GetNextDeferredEvent(event);
}

void uws_webserver_stop(uws_webserver_t server) {
	static_cast<WebServer*>(server)->StopListening();
}

void uws_webserver_delete(uws_webserver_t server) {
	delete static_cast<WebServer*>(server);
}

void uws_webserver_set_echo_mode(uws_webserver_t server, bool enabled_flag) {
	static_cast<WebServer*>(server)->SetEchoMode(enabled_flag);
}

void uws_webserver_dump_config(uws_webserver_t server) {
	static_cast<WebServer*>(server)->DumpConfiguredSettings();
}

void uws_webserver_dump_events(uws_webserver_t server) {
	static_cast<WebServer*>(server)->DumpDeferredEvents();
}

size_t uws_webserver_get_client_count(uws_webserver_t server) {
	return static_cast<WebServer*>(server)->GetNumConnectedClients();
}

size_t uws_webserver_get_event_count(uws_webserver_t server) {
	return static_cast<WebServer*>(server)->GetNumDeferredEvents();
}

size_t uws_webserver_payload_size(uws_webserver_t server) {
	return static_cast<WebServer*>(server)->GetMaxAllowedPayloadSize();
}

size_t uws_webserver_purge_connections(uws_webserver_t server) {
	return static_cast<WebServer*>(server)->PurgeFadedClients();
}

int uws_webserver_broadcast_text(uws_webserver_t server, const char* text, size_t length) {
	return static_cast<WebServer*>(server)->BroadcastTextMessage(std::string(text, length));
}

int uws_webserver_broadcast_binary(uws_webserver_t server, const char* binary, size_t length) {
	return static_cast<WebServer*>(server)->BroadcastBinaryMessage(std::string(binary, length));
}

int uws_webserver_broadcast_compressed(uws_webserver_t server, const char* compressed, size_t length) {
	return static_cast<WebServer*>(server)->BroadcastCompressedTextMessage(std::string(compressed, length));
}

int uws_webserver_send_text(uws_webserver_t server, const char* text, size_t length, const char* client_id) {
	return static_cast<WebServer*>(server)->SendTextMessageToClient(std::string(text, length), std::string(client_id));
}

int uws_webserver_send_binary(uws_webserver_t server, const char* binary, size_t length, const char* client_id) {
	return static_cast<WebServer*>(server)->SendBinaryMessageToClient(std::string(binary, length), std::string(client_id));
}

int uws_webserver_send_compressed(uws_webserver_t server, const char* compressed, size_t length, const char* client_id) {
	return static_cast<WebServer*>(server)->SendCompressedTextMessageToClient(std::string(compressed, length), std::string(client_id));
}

HttpSendStatus uws_webserver_response_write(uws_webserver_t server, const char* request_id, const char* data, size_t length) {
	return static_cast<WebServer*>(server)->WriteResponse(std::string(request_id), std::string(data, length));
}

HttpSendStatus uws_webserver_response_end(uws_webserver_t server, const char* request_id, const char* data, size_t length) {
	return static_cast<WebServer*>(server)->EndResponse(std::string(request_id), std::string(data, length));
}

HttpSendStatus uws_webserver_response_try_end(uws_webserver_t server, const char* request_id, const char* data, size_t length) {
	return static_cast<WebServer*>(server)->TryEndResponse(std::string(request_id), std::string(data, length));
}

bool uws_webserver_response_status(uws_webserver_t server, const char* request_id, const char* status_code_and_text) {
	return static_cast<WebServer*>(server)->WriteResponseStatus(std::string(request_id), status_code_and_text);
}

bool uws_webserver_response_header(uws_webserver_t server, const char* request_id, const char* key, const char* value) {
	return static_cast<WebServer*>(server)->WriteResponseHeader(std::string(request_id), std::string(key), std::string(value));
}

bool uws_webserver_has_request(uws_webserver_t server, const char* request_id) {
	return static_cast<WebServer*>(server)->HasRequest(std::string(request_id));
}

bool uws_webserver_request_method(uws_webserver_t server, const char* request_id, char* data, size_t length) {
	return static_cast<WebServer*>(server)->GetRequestMethod(std::string(request_id), data, length);
}

bool uws_webserver_request_url(uws_webserver_t server, const char* request_id, char* data, size_t length) {
	return static_cast<WebServer*>(server)->GetRequestURL(std::string(request_id), data, length);
}

bool uws_webserver_request_query(uws_webserver_t server, const char* request_id, char* data, size_t length) {
	return static_cast<WebServer*>(server)->GetRequestQuery(std::string(request_id), data, length);
}

bool uws_webserver_request_endpoint(uws_webserver_t server, const char* request_id, char* data, size_t length) {
	return static_cast<WebServer*>(server)->GetRequestEndpoint(std::string(request_id), data, length);
}

bool uws_webserver_request_serialized_headers(uws_webserver_t server, const char* request_id, char* data, size_t length) {
	return static_cast<WebServer*>(server)->GetSerializedRequestHeaders(std::string(request_id), data, length);
}

bool uws_webserver_request_header_value(uws_webserver_t server, const char* request_id, char* header, char* data, size_t length) {
	return static_cast<WebServer*>(server)->GetRequestHeader(std::string(request_id), std::string(header), data, length);
}

// Can't use C++ enum types here because LuaJIT doesn't understand them
static const std::unordered_map<int, const char*> eventNameLookupTable = {
	{ 0, "UNKNOWN_OR_INVALID_WEBSERVER_EVENT" },
	{ 1, "WEBSOCKET_CONNECTION_ESTABLISHED" },
	{ 2, "WEBSOCKET_MESSAGE_RECEIVED" },
	{ 3, "WEBSOCKET_CONNECTION_CLOSED" },
	{ 4, "SERVER_STARTED_LISTENING" },
	{ 5, "SERVER_STOPPED_LISTENING" },
	{ 6, "HTTP_REQUEST_STARTED" },
	{ 7, "HTTP_DATA_RECEIVED" },
	{ 8, "HTTP_REQUEST_FINISHED" },
	{ 9, "HTTP_CONNECTION_ABORTED" },
	{ 10, "HTTP_CONNECTION_WRITABLE" }
};

const char* uws_event_name(uws_webserver_event_t event) {
	auto iterator = eventNameLookupTable.find(event.type);

	if(iterator != eventNameLookupTable.end()) return iterator->second;
	else return "UNKNOWN_OR_INVALID_WEBSERVER_EVENT";
}

void uws_webserver_add_websocket_route(uws_webserver_t server, const char* route) {
	static_cast<WebServer*>(server)->AddWebSocketRoute(std::string(route));
}

void uws_webserver_add_get_route(uws_webserver_t server, const char* route) {
	static_cast<WebServer*>(server)->AddGetRoute(std::string(route));
}

void uws_webserver_add_post_route(uws_webserver_t server, const char* route) {
	static_cast<WebServer*>(server)->AddPostRoute(std::string(route));
}

void uws_webserver_add_options_route(uws_webserver_t server, const char* route) {
	static_cast<WebServer*>(server)->AddOptionsRoute(std::string(route));
}

void uws_webserver_add_delete_route(uws_webserver_t server, const char* route) {
	static_cast<WebServer*>(server)->AddDeleteRoute(std::string(route));
}

void uws_webserver_add_patch_route(uws_webserver_t server, const char* route) {
	static_cast<WebServer*>(server)->AddPatchRoute(std::string(route));
}

void uws_webserver_add_put_route(uws_webserver_t server, const char* route) {
	static_cast<WebServer*>(server)->AddPutRoute(std::string(route));
}

void uws_webserver_add_head_route(uws_webserver_t server, const char* route) {
	static_cast<WebServer*>(server)->AddHeadRoute(std::string(route));
}

void uws_webserver_add_any_route(uws_webserver_t server, const char* route) {
	static_cast<WebServer*>(server)->AddAnyRoute(std::string(route));
}

namespace uws_ffi {

	void* getExportsTable() {
		static struct static_uws_exports_table exports = {

			// uws
			.uws_version = uws_version,
			.uws_event_name = uws_event_name,

			// WebServer
			.uws_webserver_create = uws_webserver_create,
			.uws_webserver_listen = uws_webserver_listen,
			.uws_webserver_has_event = uws_webserver_has_event,
			.uws_webserver_get_next_event = uws_webserver_get_next_event,
			.uws_webserver_stop = uws_webserver_stop,
			.uws_webserver_delete = uws_webserver_delete,

			.uws_webserver_set_echo_mode = uws_webserver_set_echo_mode,
			.uws_webserver_dump_config = uws_webserver_dump_config,
			.uws_webserver_dump_events = uws_webserver_dump_events,

			.uws_webserver_get_client_count = uws_webserver_get_client_count,
			.uws_webserver_get_event_count = uws_webserver_get_event_count,
			.uws_webserver_payload_size = uws_webserver_payload_size,
			.uws_webserver_purge_connections = uws_webserver_purge_connections,

			.uws_webserver_broadcast_text = uws_webserver_broadcast_text,
			.uws_webserver_broadcast_binary = uws_webserver_broadcast_binary,
			.uws_webserver_broadcast_compressed = uws_webserver_broadcast_compressed,
			.uws_webserver_send_text = uws_webserver_send_text,
			.uws_webserver_send_binary = uws_webserver_send_binary,
			.uws_webserver_send_compressed = uws_webserver_send_compressed,

			.uws_webserver_response_write = uws_webserver_response_write,
			.uws_webserver_response_end = uws_webserver_response_end,
			.uws_webserver_response_try_end = uws_webserver_response_try_end,
			.uws_webserver_response_status = uws_webserver_response_status,
			.uws_webserver_response_header = uws_webserver_response_header,

			.uws_webserver_has_request = uws_webserver_has_request,
			.uws_webserver_request_method = uws_webserver_request_method,
			.uws_webserver_request_url = uws_webserver_request_url,
			.uws_webserver_request_query = uws_webserver_request_query,
			.uws_webserver_request_endpoint = uws_webserver_request_endpoint,
			.uws_webserver_request_serialized_headers = uws_webserver_request_serialized_headers,
			.uws_webserver_request_header_value = uws_webserver_request_header_value,

			.uws_webserver_add_websocket_route = uws_webserver_add_websocket_route,
			.uws_webserver_add_get_route = uws_webserver_add_get_route,
			.uws_webserver_add_post_route = uws_webserver_add_post_route,
			.uws_webserver_add_options_route = uws_webserver_add_options_route,
			.uws_webserver_add_delete_route = uws_webserver_add_delete_route,
			.uws_webserver_add_patch_route = uws_webserver_add_patch_route,
			.uws_webserver_add_put_route = uws_webserver_add_put_route,
			.uws_webserver_add_head_route = uws_webserver_add_head_route,
			.uws_webserver_add_any_route = uws_webserver_add_any_route,
		};

		return &exports;
	}

	uWS::Loop* assignEventLoop(void* existing_native_loop) {
		return uWS::Loop::get(existing_native_loop); // Actually: Assign and then return
	}

	void unassignEventLoop(uWS::Loop* loop) {
		loop->free();
	}

	std::string opCodeToString(uWS::OpCode opCode) {
		switch(opCode) {
		case uWS::OpCode::TEXT:
			return "TEXT";
		case uWS::OpCode::BINARY:
			return "BINARY";
		case uWS::OpCode::CLOSE:
			return "CLOSE";
		case uWS::OpCode::PING:
			return "PING";
		case uWS::OpCode::PONG:
			return "PONG";
		default:
			return "UNKNOWN";
		}
	}

	static const std::unordered_map<uWS::CompressOptions, std::string> compressOptionsToStringMap = {
		{ uWS::DISABLED, "DISABLED" },
		{ uWS::SHARED_COMPRESSOR, "SHARED_COMPRESSOR" },
		{ uWS::SHARED_DECOMPRESSOR, "SHARED_DECOMPRESSOR" },
		{ uWS::DEDICATED_DECOMPRESSOR_32KB, "DEDICATED_DECOMPRESSOR_32KB" },
		{ uWS::DEDICATED_DECOMPRESSOR_16KB, "DEDICATED_DECOMPRESSOR_16KB" },
		{ uWS::DEDICATED_DECOMPRESSOR_8KB, "DEDICATED_DECOMPRESSOR_8KB" },
		{ uWS::DEDICATED_DECOMPRESSOR_4KB, "DEDICATED_DECOMPRESSOR_4KB" },
		{ uWS::DEDICATED_DECOMPRESSOR_2KB, "DEDICATED_DECOMPRESSOR_2KB" },
		{ uWS::DEDICATED_DECOMPRESSOR_1KB, "DEDICATED_DECOMPRESSOR_1KB" },
		{ uWS::DEDICATED_DECOMPRESSOR_512B, "DEDICATED_DECOMPRESSOR_512B" },
		{ uWS::DEDICATED_COMPRESSOR_3KB, "DEDICATED_COMPRESSOR_3KB" },
		{ uWS::DEDICATED_COMPRESSOR_4KB, "DEDICATED_COMPRESSOR_4KB" },
		{ uWS::DEDICATED_COMPRESSOR_8KB, "DEDICATED_COMPRESSOR_8KB" },
		{ uWS::DEDICATED_COMPRESSOR_16KB, "DEDICATED_COMPRESSOR_16KB" },
		{ uWS::DEDICATED_COMPRESSOR_32KB, "DEDICATED_COMPRESSOR_32KB" },
		{ uWS::DEDICATED_COMPRESSOR_64KB, "DEDICATED_COMPRESSOR_64KB" },
		{ uWS::DEDICATED_COMPRESSOR_128KB, "DEDICATED_COMPRESSOR_128KB" },
		{ uWS::DEDICATED_COMPRESSOR_256KB, "DEDICATED_COMPRESSOR_256KB" }
	};

	std::string compressOptionsToString(uWS::CompressOptions compressOption) {

		auto iterator = compressOptionsToStringMap.find(compressOption);
		if(iterator == compressOptionsToStringMap.end()) {
			return "UNKNOWN";
		}

		return iterator->second;
	}

}