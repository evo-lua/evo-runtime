local oop = require("oop")
local uv = require("uv")

local WebSocketTestClient = oop.registerClass("WebSocketTestClient")

function WebSocketTestClient:Construct()
	local instance = {
		uvTcpHandle = uv.new_tcp(),
	}

	setmetatable(instance, self)

	return instance
end

WebSocketTestClient.__index = WebSocketTestClient
WebSocketTestClient.__call = WebSocketTestClient.Construct
setmetatable(WebSocketTestClient, WebSocketTestClient)

function WebSocketTestClient:Connect(host, port)
	host = host or "127.0.0.1"
	port = port or 9001

	local uvTcpHandle = self.uvTcpHandle

	local function onConnectionEstablished()
		self:TCP_CONNECTION_ESTABLISHED()

		uvTcpHandle:read_start(function(err, chunk)
			if not chunk then
				self:TCP_EOF_RECEIVED()
				return
			end

			self:TCP_CHUNK_RECEIVED(chunk)
		end)
	end

	uvTcpHandle:connect(host, port, onConnectionEstablished)
end

function WebSocketTestClient:Disconnect()
	self.uvTcpHandle:shutdown()
	self.uvTcpHandle:close(function()
		self:TCP_CONNECTION_CLOSED()
	end)
end

function WebSocketTestClient:TCP_CONNECTION_CLOSED()
	print("[WebSocketTestClient] TCP_CONNECTION_CLOSED")
end

function WebSocketTestClient:TCP_CONNECTION_ESTABLISHED()
	print("[WebSocketTestClient] TCP_CONNECTION_ESTABLISHED")

	-- This doesn't need to be perfectly accurate, just valid enough to be accepted as a WebSocket handshake
	local websocketsUpgradeRequest =
		"GET /chat HTTP/1.1\r\nHost: example.com:8000\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r\nSec-WebSocket-Version: 13\r\n\r\n"
	assert(self.uvTcpHandle:write(websocketsUpgradeRequest))
end

function WebSocketTestClient:Send(data)
	self.uvTcpHandle:write(data)
end

function WebSocketTestClient:TCP_EOF_RECEIVED()
	print("[WebSocketTestClient] TCP_EOF_RECEIVED")
end

function WebSocketTestClient:TCP_CHUNK_RECEIVED(chunk)
	print("[WebSocketTestClient] TCP_CHUNK_RECEIVED", #chunk)

	-- This is again sketchy in more ways than one, but it's fine since this client is only for testing a local uws-ffi server
	local upgradeResponsePattern = "HTTP/1.1 101 Switching Protocols\r\n"
		.. "Upgrade: websocket\r\n"
		.. "Connection: Upgrade\r\n"
		.. "Sec%-WebSocket%-Accept: ([%w+/]+=*)\r\n"
		.. "Date: ([%w, %-:]+)\r\n"

	-- Boldly assume it arrives in a single chunk here because we're only testing a local server
	local isProtocolUpgradeResponse = string.match(chunk, upgradeResponsePattern)
	if isProtocolUpgradeResponse then
		local responseData, secAcceptValue, dateString, uwsVersion, remainder =
			string.match(chunk, "(" .. upgradeResponsePattern .. ")(.*)")
		self:WEBSOCKET_UPGRADE_COMPLETE(responseData, secAcceptValue, dateString, uwsVersion, remainder)
	end
end

function WebSocketTestClient:WEBSOCKET_UPGRADE_COMPLETE(responseData, secAcceptValue, dateString, uwsVersion, remainder)
	print(
		"[WebSocketTestClient] WEBSOCKET_UPGRADE_COMPLETE",
		responseData,
		secAcceptValue,
		dateString,
		uwsVersion,
		remainder
	)
end

return WebSocketTestClient
