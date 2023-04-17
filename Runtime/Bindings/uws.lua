local ffi = require("ffi")

local uws = {}

uws.cdefs = [[
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

	} static_uws_exports_table;
]]

function uws.initialize()
	ffi.cdef(uws.cdefs)
end

function uws.version()
	return ffi.string(uws.bindings.uws_version())
end

return uws
