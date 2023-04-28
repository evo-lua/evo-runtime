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

const char* uws_event_name(uws_webserver_event_t event) {
	switch(event.type) {
	case DeferredEvent::Type::OPEN:
		return "WEBSOCKET_CONNECTION_ESTABLISHED";
	case DeferredEvent::Type::MESSAGE:
		return "WEBSOCKET_MESSAGE_RECEIVED";
	case DeferredEvent::Type::CLOSE:
		return "WEBSOCKET_CONNECTION_CLOSED";
	case DeferredEvent::Type::LISTEN:
		return "WEBSOCKET_SERVER_STARTED";
	case DeferredEvent::Type::SHUTDOWN:
		return "WEBSOCKET_SERVER_STOPPED";
	case DeferredEvent::Type::INVALID:
	default:
		return "UNKNOWN_OR_INVALID_WEBSOCKET_EVENT";
	}
}

void uws_webserver_add_websocket_route(uws_webserver_t server, const char* route) {
	static_cast<WebServer*>(server)->AddWebSocketRoute(std::string(route));
}

namespace uws_ffi {

	void* getExportsTable() {
		static struct static_uws_exports_table uwebsockets_exports_table;

		// uws
		uwebsockets_exports_table.uws_version = uws_version;
		uwebsockets_exports_table.uws_event_name = uws_event_name;

		// WebServer
		uwebsockets_exports_table.uws_webserver_create = uws_webserver_create;
		uwebsockets_exports_table.uws_webserver_listen = uws_webserver_listen;
		uwebsockets_exports_table.uws_webserver_has_event = uws_webserver_has_event;
		uwebsockets_exports_table.uws_webserver_get_next_event = uws_webserver_get_next_event;
		uwebsockets_exports_table.uws_webserver_stop = uws_webserver_stop;
		uwebsockets_exports_table.uws_webserver_delete = uws_webserver_delete;

		uwebsockets_exports_table.uws_webserver_set_echo_mode = uws_webserver_set_echo_mode;
		uwebsockets_exports_table.uws_webserver_dump_config = uws_webserver_dump_config;

		uwebsockets_exports_table.uws_webserver_get_client_count = uws_webserver_get_client_count;
		uwebsockets_exports_table.uws_webserver_get_event_count = uws_webserver_get_event_count;
		uwebsockets_exports_table.uws_webserver_payload_size = uws_webserver_payload_size;
		uwebsockets_exports_table.uws_webserver_purge_connections = uws_webserver_purge_connections;

		uwebsockets_exports_table.uws_webserver_broadcast_text = uws_webserver_broadcast_text;
		uwebsockets_exports_table.uws_webserver_broadcast_binary = uws_webserver_broadcast_binary;
		uwebsockets_exports_table.uws_webserver_broadcast_compressed = uws_webserver_broadcast_compressed;
		uwebsockets_exports_table.uws_webserver_send_text = uws_webserver_send_text;
		uwebsockets_exports_table.uws_webserver_send_binary = uws_webserver_send_binary;
		uwebsockets_exports_table.uws_webserver_send_compressed = uws_webserver_send_compressed;

		uwebsockets_exports_table.uws_webserver_add_websocket_route = uws_webserver_add_websocket_route;

		return &uwebsockets_exports_table;
	}

	void assignEventLoop(void* existing_native_loop) {
		uWS::Loop::get(existing_native_loop); // Actually: Assign and then return
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