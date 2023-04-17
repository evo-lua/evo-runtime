local uv = require("uv")

local WebSocketServer = require("WebSocketServer")
local WebSocketTestClient = require("WebSocketTestClient")

local server = WebSocketServer()
local clientA = WebSocketTestClient()
local clientB = WebSocketTestClient()

server:StartListening(9001)

clientA:Connect("127.0.0.1", 9001)
clientB:Connect("127.0.0.1", 9001)

-- Note: Should actually check the SendStatus here, but can probably assume no backpressure occurs while running this test ¯\_(ツ)_/¯
function server:WEBSOCKET_CONNECTION_ESTABLISHED(event, payload)
	print("[WebSocketServer] WEBSOCKET_CONNECTION_ESTABLISHED", payload.clientID)
	printf("[WebSocketServer] There are now %d connected client(s)", self:GetNumConnectedClients())

	local message = payload.clientID .. " connected\n"
	server:BroadcastTextMessage("BROADCAST/TEXT: " .. message)
	server:BroadcastBinaryMessage("BROADCAST/BIN: " .. message)
	server:BroadcastCompressedTextMessage("BROADCAST/ZLIB: " .. message)
	server:SendTextMessageToClient("SEND/TEXT: " .. message, payload.clientID)
	server:SendBinaryMessageToClient("SEND/BIN: " .. message, payload.clientID)
	server:SendCompressedTextMessageToClient("SEND/ZLIB: " .. message, payload.clientID)
end

local receivedMessagesA = {}
local receivedMessagesB = {}

function clientA:WEBSOCKET_UPGRADE_COMPLETE()
	print("[WebSocketTestClient] WEBSOCKET_UPGRADE_COMPLETE", "clientA")

	clientA.TCP_CHUNK_RECEIVED = function(_, chunk)
		local chunks = string.explode(chunk, "\n")
		for _, message in ipairs(chunks) do
			message = string.sub(message, 3, #message) -- Strip WS header
			receivedMessagesA[#receivedMessagesA + 1] = message
		end
	end
end

function clientB:WEBSOCKET_UPGRADE_COMPLETE()
	print("[WebSocketTestClient] WEBSOCKET_UPGRADE_COMPLETE", "clientB")

	clientB.TCP_CHUNK_RECEIVED = function(_, chunk)
		local chunks = string.explode(chunk, "\n")
		for _, message in ipairs(chunks) do
			message = string.sub(message, 3, #message) -- Strip WS header
			receivedMessagesB[#receivedMessagesB + 1] = message
		end
	end
end

local observedEvents = {}

local originalEventHandler = server.OnEvent
local function storeObservedEvent(self, eventName, payload)
	originalEventHandler(self, eventName, payload)

	observedEvents[#observedEvents + 1] = { event = eventName, payload = payload }
end

server.OnEvent = storeObservedEvent

local expectedEvents = {
	"WEBSOCKET_SERVER_STARTED",
	"WEBSOCKET_CONNECTION_ESTABLISHED",
	"WEBSOCKET_CONNECTION_ESTABLISHED",
	"WEBSOCKET_CONNECTION_CLOSED",
	"WEBSOCKET_CONNECTION_CLOSED",
	"WEBSOCKET_SERVER_STOPPED",
}

local function assertMessagesWereReceived()
	-- 2x3 broadcast for each client, 3x direct notification
	assertEquals(#receivedMessagesA, 9)
	assertEquals(#receivedMessagesB, 9)

	-- Note: WebSockets use TCP, so the order of messages is guaranteed
	-- A connects first
	assertEquals(receivedMessagesA[1]:find("BROADCAST/TEXT"), 1)
	assertEquals(receivedMessagesA[2]:find("BROADCAST/BIN"), 1)
	assertEquals(receivedMessagesA[3]:find("BROADCAST/ZLIB"), 1)
	assertEquals(receivedMessagesA[4]:find("SEND/TEXT"), 1)
	assertEquals(receivedMessagesA[5]:find("SEND/BIN"), 1)
	assertEquals(receivedMessagesA[6]:find("SEND/ZLIB"), 1)
	-- B connected after B (relies on libuv handling events in order)
	assertEquals(receivedMessagesA[7]:find("BROADCAST/TEXT"), 1)
	assertEquals(receivedMessagesA[8]:find("BROADCAST/BIN"), 1)
	assertEquals(receivedMessagesA[9]:find("BROADCAST/ZLIB"), 1)
	-- B connects second, so it receives the broadcasts for A right away
	assertEquals(receivedMessagesB[1]:find("BROADCAST/TEXT"), 1)
	assertEquals(receivedMessagesB[2]:find("BROADCAST/BIN"), 1)
	assertEquals(receivedMessagesB[3]:find("BROADCAST/ZLIB"), 1)
	-- And then it receives its own notifications
	assertEquals(receivedMessagesB[4]:find("BROADCAST/TEXT"), 1)
	assertEquals(receivedMessagesB[5]:find("BROADCAST/BIN"), 1)
	assertEquals(receivedMessagesB[6]:find("BROADCAST/ZLIB"), 1)
	assertEquals(receivedMessagesB[7]:find("SEND/TEXT"), 1)
	assertEquals(receivedMessagesB[8]:find("SEND/BIN"), 1)
	assertEquals(receivedMessagesB[9]:find("SEND/ZLIB"), 1)
end

local function assertDeferredEventsAreStored()
	assertEquals(#observedEvents, #expectedEvents)
	for i = 1, #expectedEvents do
		assertEquals(observedEvents[i].event, expectedEvents[i])
	end
end

local function resumeAfterDelay(delay, callback)
	local timer = uv.new_timer()

	timer:start(delay, 0, function()
		callback()

		timer:stop()
		timer:close()
	end)
end

resumeAfterDelay(100, function()
	clientA:Disconnect()
	clientB:Disconnect()

	resumeAfterDelay(100, function()
		server:StopListening()

		resumeAfterDelay(100, function()
			assertMessagesWereReceived()
			assertDeferredEventsAreStored()
			uv.stop()
		end)
	end)
end)

uv.run()
