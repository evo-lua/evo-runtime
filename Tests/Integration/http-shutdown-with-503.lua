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

		-- We have to send a request (at least up to the headers) so that the server keeps the connection open until shutdown
		local getRequest = "GET /test456.htm HTTP/1.1\r\nUser-Agent: evo\r\nHost: www.example.org\r\n\r\n"
		client:write(getRequest)
	end)

	self.client = client

	return client
end

function Test:Run()
	C_Timer.After(1000, function()
		self.server:StopListening() -- Should force shutdown with 503 response code since the client is still connected
		C_Timer.After(1000, function()
			uv.stop() -- Client should have received the 503 response by now
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

	assertTrue(table_contains(receivedLines, "HTTP/1.1 503 Service Unavailable"))
	assertTrue(table_contains(receivedLines, "Content-Type: text/plain"))
	assertTrue(table_contains(receivedLines, "Content-Length: 41"))
	assertTrue(table_contains(receivedLines, "Service Unavailable: Server shutting down"))
end

Test:Setup()
Test:Run()
Test:Teardown()
