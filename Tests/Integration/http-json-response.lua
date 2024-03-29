local uv = require("uv")
local HttpServer = require("HttpServer")

local table_contains = table.contains

local Test = {
	port = 9004,
	receivedChunks = buffer.new(),
}

function Test:Setup()
	self:CreateServer()
	self:CreateClient()
end

function Test:CreateServer()
	local server = HttpServer()

	server:AddRoute("/*", "GET")
	server:StartListening(self.port)

	server.HTTP_REQUEST_FINISHED = function(_, event, payload)
		print("[HttpServer] HTTP_REQUEST_FINISHED", payload.clientID)
		server:WriteStatus(payload.clientID, "200 OK")
		server:WriteHeader(payload.clientID, "Content-Type", "application/json")
		server:SendResponse(payload.clientID, '{ "test": 123 }')
	end

	self.server = server

	return server
end

function Test:CreateClient()
	local client = uv.new_tcp()

	client:connect("127.0.0.1", self.port, function()
		client:read_start(function(err, chunk)
			if err then
				error(err, 0)
			end

			if not chunk then
				return -- FIN received, connection shutting down
			end

			self.receivedChunks:put(chunk)
		end)

		local getRequest = "GET /something.json HTTP/1.1\r\nUser-Agent: evo\r\nHost: www.example.org\r\n\r\n"
		client:write(getRequest)
	end)

	self.client = client

	return client
end

function Test:Run()
	C_Timer.After(1000, function()
		self.server:StopListening()
		C_Timer.After(1000, function()
			uv.stop()
		end)
	end)
	uv.run()
end

function Test:Teardown()
	self.client:shutdown()
	self.client:close()
	self:AssertClientReceivedShutdownResponse()
end

function Test:AssertClientReceivedShutdownResponse()
	local receivedLines = string.explode(tostring(self.receivedChunks), "\r\n")

	assertEquals(#receivedLines, 5)

	assertTrue(table_contains(receivedLines, "HTTP/1.1 200 OK"))
	assertTrue(table_contains(receivedLines, "Content-Type: application/json"))
	assertTrue(table_contains(receivedLines, "Content-Length: 15"))
	assertTrue(table_contains(receivedLines, '{ "test": 123 }'))
end

Test:Setup()
Test:Run()
Test:Teardown()
