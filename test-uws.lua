local ffi = require("ffi")
local uv = require("uv")
local uws = require("uws")

local uws_create_app = uws.bindings.uws_create_app
local uws_ws = uws.bindings.uws_ws
local uws_app_listen = uws.bindings.uws_app_listen
local uws_app_run = uws.bindings.uws_app_run

-- static void idle_cb(uv_idle_t* handle) {
-- // std::cout << "idler be idling" << std::endl;
-- }

local idler = uv.new_idle()

-- // uv_idle_init(loop, &idler);

idler:start(function()
	print("Idler be idling")
end)
-- // uv_idle_start(&idler, idle_cb);
-- // uws_test((void*)loop);
-- // // http_client_test();
-- // uv_run(loop, UV_RUN_DEFAULT);

local socketOptions = ffi.new("struct us_socket_context_options_t")

local app = uws_create_app(false, socketOptions)
-- .key_file_name = "../misc/key.pem",
-- .cert_file_name = "../misc/cert.pem",
-- .passphrase = "1234" });

local socketBehavior = ffi.new("struct uws_socket_behavior_t")
uws_ws(false, app, "/*", socketBehavior, nil)

-- .compression = uws_compress_options_t::SHARED_COMPRESSOR,
-- .maxPayloadLength = 16 * 1024,
-- .idleTimeout = 12,
-- .maxBackpressure = 1 * 1024 * 1024,
-- .upgrade = NULL,
-- .open = open_handler,
-- .message = message_handler,
-- .drain = drain_handler,
-- .ping = ping_handler,
-- .pong = pong_handler,
-- .close = close_handler,
-- },

-- todo listen_handler in exports table, queue msg
local function listen_handler(listen_socket, config, user_data)
	-- void listen_handler(struct us_listen_socket_t* listen_socket, uws_app_listen_config_t config, void* user_data) {
	-- 	std::cout << "listen_handler" << std::endl;
	if listen_socket then
		print("listen ok")
	else
		print("listen failed")
	end
	-- 		printf("Listening on port wss://localhost:%d\n", config.port);
	-- 	} else {
	-- 		std::cout << "Failed to load certs or to bind to port" << std::endl;
	-- 	}
	-- }
end
uws_app_listen(false, app, 9001, uws.bindings.listen_handler, nil);

uws_app_run(false, app);

uv.run()
