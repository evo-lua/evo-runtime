local uv = require("uv")

local WebSocketServer = require("WebSocketServer")
local WebSocketTestClient = require("WebSocketTestClient")

local server = WebSocketServer()
local client = WebSocketTestClient()

server:StartListening(9001)

client:Connect("127.0.0.1", 9001)

local observedEvents = {}

function client:WEBSOCKET_UPGRADE_COMPLETE()
	print("[WebSocketTestClient] WEBSOCKET_UPGRADE_COMPLETE")
	local helloWorldTextFrame = "\x81\x8B\x12\x34\x56\x78\x5A\x51\x3A\x14\x7D\x14\x21\x17\x60\x58\x32"
	client:Send(helloWorldTextFrame)
end

local originalEventHandler = server.OnEvent
local function storeObservedEvent(self, eventName, payload)
	originalEventHandler(self, eventName, payload)

	observedEvents[#observedEvents + 1] = { event = eventName, payload = payload }
end

server.OnEvent = storeObservedEvent

local expectedEvents = {
	"WEBSOCKET_SERVER_STARTED",
	"WEBSOCKET_CONNECTION_ESTABLISHED",
	"WEBSOCKET_MESSAGE_RECEIVED",
	"WEBSOCKET_CONNECTION_CLOSED",
	"WEBSOCKET_SERVER_STOPPED",
}

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
	client:Disconnect()

	resumeAfterDelay(100, function()
		server:StopListening()

		resumeAfterDelay(100, function()
			assertDeferredEventsAreStored()
			uv.stop()
		end)
	end)
end)

uv.run()
