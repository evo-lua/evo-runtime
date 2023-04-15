local uv = require("uv")
local uws = require("uws")

local WebSocketTestClient = require("WebSocketTestClient")

local server = uws.bindings.uws_webserver_create()
local client = WebSocketTestClient()

uws.bindings.uws_webserver_listen(server, 9001)
uws.bindings.uws_webserver_set_echo_mode(server, true)

print("WebServer created with the following settings:")
uws.bindings.uws_webserver_dump_config(server)

client:Connect("127.0.0.1", 9001)

local receivedEchoedMessage = nil
local hasUpdatedClientCount = false

-- Override only after the WS upgrade is complete to make sure the echoed messages arrive correctly
local function registerNewMessageHandler()
	function client:TCP_CHUNK_RECEIVED(chunk)
		chunk = string.sub(chunk, 3, #chunk) -- Strip header to make it easier to compare

		print("[WebSocketTestClient] TCP_CHUNK_RECEIVED: " .. chunk)
		if chunk == "Hello world" then
			receivedEchoedMessage = true
		end
	end
end

function client:WEBSOCKET_UPGRADE_COMPLETE()
	print("[WebSocketTestClient] WEBSOCKET_UPGRADE_COMPLETE")
	local helloWorldTextFrame = "\x81\x8B\x12\x34\x56\x78\x5A\x51\x3A\x14\x7D\x14\x21\x17\x60\x58\x32"
	client:Send(helloWorldTextFrame)

	local numConnectedClients = uws.bindings.uws_webserver_get_client_count(server)
	if numConnectedClients == 1 then
		hasUpdatedClientCount = true
	end

	registerNewMessageHandler()
end

local shutdownTimer = uv.new_timer()
shutdownTimer:start(250, 0, function()
	client:Disconnect()

	uws.bindings.uws_webserver_stop(server)
	uws.bindings.uws_webserver_delete(server)

	shutdownTimer:stop()
	shutdownTimer:close()

	uv.stop()

	assertTrue(receivedEchoedMessage)
	assertTrue(hasUpdatedClientCount)
end)

uv.run()
