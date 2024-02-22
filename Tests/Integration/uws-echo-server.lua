local uv = require("uv")
local uws = require("uws")

local port = 8888

local WebSocketTestClient = require("WebSocketTestClient")

local server = uws.bindings.uws_webserver_create()
local client = WebSocketTestClient()

uws.bindings.uws_webserver_add_websocket_route(server, "/*")
uws.bindings.uws_webserver_listen(server, port)
uws.bindings.uws_webserver_set_echo_mode(server, true)

print("WebServer created with the following settings:")
uws.bindings.uws_webserver_dump_config(server)

client:Connect("127.0.0.1", port)

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
	local helloWorldTextFrame = "\129\139\18\52\86\120\90\81\58\20\125\20\33\23\96\88\50"
	client:Send(helloWorldTextFrame)

	local numConnectedClients = uws.bindings.uws_webserver_get_client_count(server)
	if numConnectedClients == 1 then
		hasUpdatedClientCount = true
	end

	registerNewMessageHandler()
end

local shutdownTicker
shutdownTicker = C_Timer.NewTicker(100, function()
	if not receivedEchoedMessage then
		print("Waiting for received echo message...")
		return
	end

	if not hasUpdatedClientCount then
		print("Waiting for updated client count...")
		return
	end

	client:Disconnect()

	uws.bindings.uws_webserver_stop(server)
	uws.bindings.uws_webserver_delete(server)

	shutdownTicker:stop()
	shutdownTicker:close()

	uv.stop()
end)

uv.run()
