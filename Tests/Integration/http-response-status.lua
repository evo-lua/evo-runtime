local uv = require("uv")
local HttpServer = require("HttpServer")

local table_contains = table.contains

local Test = {
	port = 9004,
	receivedChunks = {},
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
		server:WriteStatus(payload.clientID, "404 Not Found")
		server:SendResponse(payload.clientID, "")
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

			local lines = string.explode(chunk, "\r\n")
			for _, line in ipairs(lines) do
				self.receivedChunks[#self.receivedChunks + 1] = line
			end
		end)

		local getRequest = "GET /does-not-exist.html HTTP/1.1\r\nUser-Agent: evo\r\nHost: www.example.org\r\n\r\n"
		client:write(getRequest)
	end)

	self.client = client

	return client
end

function Test:Run()
	C_Timer.After(100, function()
		self.server:StopListening()
		C_Timer.After(100, function()
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
	dump(self.receivedChunks)
	assertEquals(#self.receivedChunks, 3)

	assertTrue(table_contains(self.receivedChunks, "HTTP/1.1 404 Not Found"))
	assertTrue(table_contains(self.receivedChunks, "Content-Length: 0"))
end

Test:Setup()
Test:Run()
Test:Teardown()
