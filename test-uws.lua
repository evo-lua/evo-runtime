local ffi = require("ffi")
local uv = require("uv")
local uws = require("uws")

local uws_create_app = uws.bindings.uws_create_app
local uws_ws = uws.bindings.uws_ws
local uws_app_listen = uws.bindings.uws_app_listen
local uws_app_run = uws.bindings.uws_app_run

local idler = uv.new_timer()

idler:start(5000, 5000, function()
	print("The event loop is still alive")
end)

local socketOptions = ffi.new("struct us_socket_context_options_t")

local app = uws_create_app(false, socketOptions)
-- .key_file_name = "../misc/key.pem",
-- .cert_file_name = "../misc/cert.pem",
-- .passphrase = "1234" });

local socketBehavior = ffi.new("struct uws_socket_behavior_t")
-- socketBehavior.upgrade = uws.bindings.upgrade_handler -- TBD why does this block everything else?
socketBehavior.open = uws.bindings.open_handler
socketBehavior.message = uws.bindings.message_handler
socketBehavior.drain = uws.bindings.drain_handler
-- socketBehavior.ping = uws.bindings.ping_handler
-- socketBehavior.pong = uws.bindings.pong_handler
socketBehavior.close = uws.bindings.close_handler
socketBehavior.subscription = uws.bindings.subscription_handler

local MAX_AUTOBAHN_MESSAGE_SIZE = 16 * 1024 * 1024 -- AB test suite sends 16M max? (perf test cases)
socketBehavior.maxPayloadLength = MAX_AUTOBAHN_MESSAGE_SIZE + 1 -- 16 * 1024
socketBehavior.maxBackpressure = 1 * 1024 * 1024
socketBehavior.idleTimeout = 8 -- 12

-- .compression = uws_compress_options_t::SHARED_COMPRESSOR,

uws_ws(false, app, "/*", socketBehavior, nil)

uws_app_listen(false, app, 9001, uws.bindings.listen_handler, nil)

uws_app_run(false, app)

uv.run()
