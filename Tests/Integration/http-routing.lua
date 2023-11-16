local uv = require("uv")
local HttpServer = require("HttpServer")

local Test = {
	port = 9002,
	exampleRequests = {
		GET = "GET /example HTTP/1.1\r\nHost: example.com\r\n\r\n",
		POST = "POST /example HTTP/1.1\r\nHost: example.com\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: 10\r\n\r\ndata=value",
		OPTIONS = "OPTIONS /example HTTP/1.1\r\nHost: example.com\r\n\r\n",
		DELETE = "DELETE /example HTTP/1.1\r\nHost: example.com\r\n\r\n",
		PATCH = 'PATCH /example HTTP/1.1\r\nHost: example.com\r\nContent-Type: application/json\r\nContent-Length: 16\r\n\r\n{"key": "value"}',
		PUT = 'PUT /example HTTP/1.1\r\nHost: example.com\r\nContent-Type: application/json\r\nContent-Length: 16\r\n\r\n{"key": "value"}',
		HEAD = "HEAD /example HTTP/1.1\r\nHost: example.com\r\n\r\n",
	},
	clients = {},
	receivedChunks = {
		GET = buffer.new(),
		POST = buffer.new(),
		OPTIONS = buffer.new(),
		DELETE = buffer.new(),
		PATCH = buffer.new(),
		PUT = buffer.new(),
		HEAD = buffer.new(),
	},
}

function Test:Setup()
	self:CreateServer()
	self:CreateClients()
end

function Test:CreateServer()
	local server = HttpServer()

	function server.HTTP_REQUEST_FINISHED(_, event, payload)
		print("[HttpServer] HTTP_REQUEST_FINISHED", payload.clientID)
		server:SendResponse(payload.clientID, "This is the response body")
	end

	server:StartListening(self.port)

	-- Specificity is handled by uws, so this remains rather basic
	server:AddRoute("/*", "GET")
	server:AddRoute("/*", "POST")
	server:AddRoute("/*", "OPTIONS")
	server:AddRoute("/*", "DELETE")
	server:AddRoute("/*", "PATCH")
	server:AddRoute("/*", "PUT")
	server:AddRoute("/*", "HEAD")

	local function setResponseHandler()
		function server.HTTP_REQUEST_FINISHED(_, event, payload)
			print("[HttpServer] HTTP_REQUEST_FINISHED")

			local requestID = payload.clientID
			local requestDetails = server:GetRequestDetails(requestID)
			local requestMethod = requestDetails.method

			server:SendResponse(requestID, requestMethod .. " response body")
		end
	end

	setResponseHandler(server)

	self.server = server
end

function Test:CreateClients()
	for method, _ in pairs(self.exampleRequests) do
		self:CreateClient(method)
	end
end

function Test:CreateClient(method)
	local client = uv.new_tcp()

	client:connect("127.0.0.1", self.port, function()
		client:read_start(function(err, chunk)
			if err then
				error(err, 0)
				return
			end

			if chunk then
				self.receivedChunks[method]:put(chunk)
			end
		end)

		client:write(self.exampleRequests[method])
	end)

	self.clients[method] = client
end

function Test:Run()
	self.ticker = C_Timer.NewTicker(100, function()
		print("Checking receive buffers...")

		local receivedLines = {
			GET = string.explode(tostring(self.receivedChunks.GET), "\r\n"),
			POST = string.explode(tostring(self.receivedChunks.POST), "\r\n"),
			OPTIONS = string.explode(tostring(self.receivedChunks.OPTIONS), "\r\n"),
			DELETE = string.explode(tostring(self.receivedChunks.DELETE), "\r\n"),
			PATCH = string.explode(tostring(self.receivedChunks.PATCH), "\r\n"),
			PUT = string.explode(tostring(self.receivedChunks.PUT), "\r\n"),
			HEAD = string.explode(tostring(self.receivedChunks.HEAD), "\r\n"),
		}

		for httpMethod, exampleRequest in pairs(self.exampleRequests) do
			local hasReceivedResponseBody = table.contains(receivedLines[httpMethod], httpMethod .. " response body")
			printf("Received %d bytes for method %s", #self.receivedChunks[httpMethod], httpMethod)
			if not hasReceivedResponseBody then
				printf("Missing chunks for method %s", httpMethod)
				return
			end
		end

		print("All chunks received - shutting down...")
		Test:Teardown()
	end)

	uv.run()
end

function Test:Teardown()
	self.server:StopListening()

	self.ticker:stop()
	for method, client in pairs(self.clients) do
		client:shutdown()
		client:close()
	end
	uv.stop()
end

Test:Setup()
Test:Run()
