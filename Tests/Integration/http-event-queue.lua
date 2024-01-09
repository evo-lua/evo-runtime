local uv = require("uv")
local HttpServer = require("HttpServer")

local Test = {
	port = 9003,
	observedEvents = {},
}

function Test:Setup()
	self:CreateServer()
	self:CreateClient()
end

function Test:CreateClient()
	local client = uv.new_tcp()

	client:connect("127.0.0.1", self.port, function()
		client:read_start(function(err, chunk)
			if err then
				error(err, 0)
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
	C_Timer.After(1000, function()
		self.client:shutdown()
		self.client:close()

		C_Timer.After(1000, function()
			self.server:StopListening()

			C_Timer.After(1000, function()
				uv.stop()
			end)
		end)
	end)
	uv.run()
end

function Test:Teardown()
	self:AssertDeferredEventsAreStored()
end

function Test:AssertDeferredEventsAreStored()
	local expectedEvents = {
		"SERVER_STARTED_LISTENING",
		"HTTP_REQUEST_STARTED",
		"HTTP_REQUEST_FINISHED",
		"SERVER_STOPPED_LISTENING",
	}

	assertEquals(#self.observedEvents, #expectedEvents)
	for i = 1, #expectedEvents do
		assertEquals(self.observedEvents[i].event, expectedEvents[i])
	end
end

Test:Setup()
Test:Run()
Test:Teardown()
