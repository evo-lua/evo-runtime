local ffi = require("ffi")
local uv = require("uv")
local uws = require("uws")

local uws_create_app = uws.bindings.uws_create_app
local uws_ws = uws.bindings.uws_ws
local uws_app_listen = uws.bindings.uws_app_listen
local uws_app_run = uws.bindings.uws_app_run

local idler = uv.new_timer()

idler:start(1000, 1000, function()
	print("The event loop is still ticking")
end)

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

uws_app_listen(false, app, 9001, uws.bindings.listen_handler, nil);

uws_app_run(false, app);

uv.run()
