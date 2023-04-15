local uv = require("uv")

local WebSocketServer = require("WebSocketServer")
local WebSocketTestClient = require("WebSocketTestClient")

local server = WebSocketServer()
local client = WebSocketTestClient()

server:StartListening(9001)
server:SetEchoMode(true)

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
	local helloWorldTextFrame = "\x81\x8B\x12\x34\x56\x78\x5A\x51\x3A\x14\x7D\x14\x21\x17\x60\x58\x32"
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
