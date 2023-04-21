local ffi = require("ffi")
local uv = require("uv")
local uws = require("uws")

local port = 8887

local WebSocketTestClient = require("WebSocketTestClient")

local server = uws.bindings.uws_webserver_create()
local client = WebSocketTestClient()

uws.bindings.uws_webserver_listen(server, port)

client:Connect("127.0.0.1", port)

function client:WEBSOCKET_UPGRADE_COMPLETE()
	print("[WebSocketTestClient] WEBSOCKET_UPGRADE_COMPLETE")
	local helloWorldTextFrame = "\x81\x8B\x12\x34\x56\x78\x5A\x51\x3A\x14\x7D\x14\x21\x17\x60\x58\x32"
	client:Send(helloWorldTextFrame)
end

local function assertEventQueueWorks()
	local event = ffi.new("uws_webserver_event_t")
	local payloadSizeInBytes = 16 * 1024 * 1024 -- TODO read from server instance
	local payloadBuffer = ffi.new("char[?]", payloadSizeInBytes)
	event.payload = payloadBuffer

	local numDeferredEvents = uws.bindings.uws_webserver_get_event_count(server)
	assertEquals(tonumber(numDeferredEvents), 5) -- start, connect, disconnect, message, stop

	uws.bindings.uws_webserver_get_next_event(server, event)
end

local shutdownTimer = uv.new_timer()
shutdownTimer:start(250, 0, function()
	client:Disconnect()

	uws.bindings.uws_webserver_stop(server)

	assertEventQueueWorks() -- Must call before delete as the event queue will be cleared, as well

	uws.bindings.uws_webserver_delete(server)

	shutdownTimer:stop()
	shutdownTimer:close()

	uv.stop()
end)

uv.run()
