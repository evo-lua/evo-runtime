local assertions = require("assertions")
local uv = require("uv")
local HttpServer = require("HttpServer")

local assertEquals = assertions.assertEquals

local Test = {
	port = 9003,
	observedEvents = {},
	expectedEvents = {
		"SERVER_STARTED_LISTENING",
		"HTTP_REQUEST_STARTED",
		"HTTP_REQUEST_FINISHED",
		"SERVER_STOPPED_LISTENING",
	},
	didClientReceiveResponse = false,
}

function Test:Setup()
	self:CreateServer()
	self:CreateClient()
end

function Test:CreateClient()
	local client = uv.new_tcp()
	local receivedBytes = buffer.new()

	client:connect("127.0.0.1", self.port, function()
		client:read_start(function(err, chunk)
			if err then
				error(err, 0)
			end

			if not chunk then
				print("[Client] Received EOF from server, dropping TCP connection ...")
				return
			end

			printf("[Client] Received chunk of size %d: %s", #chunk, chunk)
			receivedBytes:put(chunk)
			if tostring(receivedBytes):match("This is the response body") then
				printf("[Client] Received response body from server, going away ...")
				client:shutdown()
				client:close()
				self.didClientReceiveResponse = true
				self.server:StopListening()
			end
		end)

		local getRequest = "GET /test123.htm HTTP/1.1\r\nHost: www.example.org\r\n\r\n"
		client:write(getRequest)
	end)

	self.client = client
end

function Test:CreateServer()
	local server = HttpServer()

	server:AddRoute("/*", "GET")
	server:StartListening(self.port)

	local function setCustomEventHandler()
		local originalEventHandler = server.OnEvent
		local function storeObservedEvent(_, eventName, payload)
			originalEventHandler(server, eventName, payload)
			printf("[HttpServer] Observed event %s (client ID: %s)", eventName, payload.clientID)
			self.observedEvents[#self.observedEvents + 1] = { event = eventName, payload = payload }
		end

		function server.HTTP_REQUEST_FINISHED(_, event, payload)
			print("[HttpServer] HTTP_REQUEST_FINISHED", payload.clientID)
			server:SendResponse(payload.clientID, "This is the response body")
		end

		server.OnEvent = storeObservedEvent
	end

	setCustomEventHandler(server)

	self.server = server
end

function Test:Run()
	self.statusUpdateTicker = C_Timer.NewTicker(1000, function()
		printf("Events observed so far: %d/%d", #self.observedEvents, #self.expectedEvents)
		if #self.observedEvents == #self.expectedEvents then
			self.statusUpdateTicker:stop()
			uv.stop()
		end
	end)

	uv.run()
end

function Test:Teardown()
	self:AssertDeferredEventsAreStored()
end

function Test:AssertDeferredEventsAreStored()
	assertEquals(#self.observedEvents, #self.expectedEvents)
	for i = 1, #self.expectedEvents do
		assertEquals(self.observedEvents[i].event, self.expectedEvents[i])
	end
end

Test:Setup()
Test:Run()
Test:Teardown()
