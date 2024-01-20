local uv = require("uv")

local port = 8889

local WebSocketServer = require("WebSocketServer")
local WebSocketTestClient = require("WebSocketTestClient")

local server = WebSocketServer()
local client = WebSocketTestClient()

server:StartListening(port)
server:SetEchoMode(true)

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
	local helloWorldTextFrame = "\129\139\18\52\86\120\90\81\58\20\125\20\33\23\96\88\50"
	client:Send(helloWorldTextFrame)

	local numConnectedClients = server:GetNumConnectedClients()
	if numConnectedClients == 1 then
		hasUpdatedClientCount = true
	end

	registerNewMessageHandler()
end

local shutdownTimer = uv.new_timer()
shutdownTimer:start(250, 0, function()
	client:Disconnect()
	server:StopListening()

	shutdownTimer:stop()
	shutdownTimer:close()

	uv.stop()

	assertTrue(receivedEchoedMessage)
	assertTrue(hasUpdatedClientCount)
end)

uv.run()
