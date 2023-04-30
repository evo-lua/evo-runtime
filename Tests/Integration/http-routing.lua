local uv = require("uv")
local HttpServer = require("HttpServer")

local Test = {
	port = 9002,
	exampleRequests = {
		GET = "GET /example HTTP/1.1\r\nHost: example.com\r\n\r\n",
		POST = "POST /example HTTP/1.1\r\nHost: example.com\r\nContent-Type: application/x-www-form-urlencoded\r\nContent-Length: 11\r\n\r\ndata=value\r\n",
		OPTIONS = "OPTIONS /example HTTP/1.1\r\nHost: example.com\r\n\r\n",
		DELETE = "DELETE /example HTTP/1.1\r\nHost: example.com\r\n\r\n",
		PATCH = 'PATCH /example HTTP/1.1\r\nHost: example.com\r\nContent-Type: application/json\r\nContent-Length: 18\r\n\r\n{"key": "value"}\r\n\r\n',
		PUT = 'PUT /example HTTP/1.1\r\nHost: example.com\r\nContent-Type: application/json\r\nContent-Length: 18\r\n\r\n{"key": "value"}\r\n',
		HEAD = "HEAD /example HTTP/1.1\r\nHost: example.com\r\n\r\n",
	},
	clients = {},
	receivedChunks = {
		GET = {},
		POST = {},
		OPTIONS = {},
		DELETE = {},
		PATCH = {},
		PUT = {},
		HEAD = {},
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
				local lines = string.explode(chunk, "\r\n")
				for _, line in ipairs(lines) do
					self.receivedChunks[method][#self.receivedChunks[method] + 1] = line
				end
			end
		end)

		client:write(self.exampleRequests[method])
	end)

	self.clients[method] = client
end

function Test:Run()
	C_Timer.After(100, function()
		C_Timer.After(100, function()
			self.server:StopListening()

			for method, client in pairs(self.clients) do
				client:shutdown()
				client:close()
			end

			C_Timer.After(100, function()
				uv.stop()
			end)
		end)
	end)
	uv.run()
end

function Test:Teardown()
	self:AssertClientsReceivedResponses()
end

function Test:AssertClientsReceivedResponses()
	assertTrue(table.contains(self.receivedChunks.GET, "GET response body"))
	assertTrue(table.contains(self.receivedChunks.POST, "POST response body"))
	assertTrue(table.contains(self.receivedChunks.OPTIONS, "OPTIONS response body"))
	assertTrue(table.contains(self.receivedChunks.DELETE, "DELETE response body"))
	assertTrue(table.contains(self.receivedChunks.PATCH, "PATCH response body"))
	assertTrue(table.contains(self.receivedChunks.PUT, "PUT response body"))
	assertTrue(table.contains(self.receivedChunks.HEAD, "HEAD response body"))
end

Test:Setup()
Test:Run()
Test:Teardown()
