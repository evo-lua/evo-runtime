local uv = require("uv")

local port = 8886

local WebSocketServer = require("WebSocketServer")
local WebSocketTestClient = require("WebSocketTestClient")

local server = WebSocketServer()
local client = WebSocketTestClient()

server:StartListening(port)

client:Connect("127.0.0.1", port)

local observedEvents = {}

function client:WEBSOCKET_UPGRADE_COMPLETE()
	print("[WebSocketTestClient] WEBSOCKET_UPGRADE_COMPLETE")
	local helloWorldTextFrame = "\129\139\18\52\86\120\90\81\58\20\125\20\33\23\96\88\50"
	client:Send(helloWorldTextFrame)
end

local originalEventHandler = server.OnEvent
local function storeObservedEvent(self, eventName, payload)
	originalEventHandler(self, eventName, payload)

	observedEvents[#observedEvents + 1] = { event = eventName, payload = payload }
end

server.OnEvent = storeObservedEvent

local expectedEvents = {
	"SERVER_STARTED_LISTENING",
	"WEBSOCKET_CONNECTION_ESTABLISHED",
	"WEBSOCKET_MESSAGE_RECEIVED",
	"WEBSOCKET_CONNECTION_CLOSED",
	"SERVER_STOPPED_LISTENING",
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
