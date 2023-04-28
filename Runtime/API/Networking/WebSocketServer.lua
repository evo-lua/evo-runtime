local ffi = require("ffi")
local uv = require("uv")
local uws = require("uws")
local validation = require("validation")

local WebSocketServer = {
	DEFAULT_PORT = 9001,
}

local tonumber = tonumber

function WebSocketServer:Construct()
	local instance = {
		pollingUpdateTimeInMilliseconds = 16,
		pollingUpdateTimer = uv.new_timer(),
		nativeHandle = uws.bindings.uws_webserver_create(),
	}

	local maxPayloadSize = uws.bindings.uws_webserver_payload_size(instance.nativeHandle)
	instance.maxPayloadSize = tonumber(maxPayloadSize)

	local preallocatedEventBuffer = ffi.new("uws_webserver_event_t")
	local payload = ffi.new("char[?]", instance.maxPayloadSize + 1)
	preallocatedEventBuffer.payload = payload

	-- Since cdata fields aren't GC anchors, manually keep the payload buffer alive
	instance.preallocatedPayloadBuffer = payload
	instance.preallocatedEventBuffer = preallocatedEventBuffer

	-- Should be made configurable probably, but that can wait
	uws.bindings.uws_webserver_add_websocket_route(instance.nativeHandle, "/*")

	setmetatable(instance, self)

	return instance
end

WebSocketServer.__index = WebSocketServer
WebSocketServer.__call = WebSocketServer.Construct
WebSocketServer.__gc = function(self)
	uws.bindings.uws_webserver_delete(self.nativeHandle)
end

setmetatable(WebSocketServer, WebSocketServer)

function WebSocketServer:StartListening(port)
	port = port or WebSocketServer.DEFAULT_PORT

	uws.bindings.uws_webserver_listen(self.nativeHandle, port)

	self.pollingUpdateTimer:start(0, self.pollingUpdateTimeInMilliseconds, function()
		uws.bindings.uws_webserver_purge_connections(self.nativeHandle)
		self:ProcessDeferredEvents()
		self:ASYNC_POLLING_UPDATE()
	end)
end

function WebSocketServer:StopListening()
	uws.bindings.uws_webserver_stop(self.nativeHandle)

	-- Make sure to flush all remaining events and process any leftovers to shut down cleanly
	self.pollingUpdateTimer:stop()
	uws.bindings.uws_webserver_purge_connections(self.nativeHandle)
	self:ProcessDeferredEvents()
	self:ASYNC_POLLING_UPDATE()
end

function WebSocketServer:SetEchoMode(enabledFlag)
	validation.validateBoolean(enabledFlag, "enabledFlag")
	uws.bindings.uws_webserver_set_echo_mode(self.nativeHandle, enabledFlag)
end

function WebSocketServer:ProcessDeferredEvents()
	local cdata = self.preallocatedEventBuffer

	while uws.bindings.uws_webserver_has_event(self.nativeHandle) do
		uws.bindings.uws_webserver_get_next_event(self.nativeHandle, cdata)

		local eventType = tonumber(cdata.type)
		local eventName = ffi.string(uws.bindings.uws_event_name(cdata))
		local clientID = ffi.string(cdata.clientID)
		local payloadBuffer = ffi.string(cdata.payload, cdata.payload_size)

		local payload = {
			eventTypeID = eventType,
			clientID = clientID,
			message = payloadBuffer,
		}

		self:OnEvent(eventName, payload)
	end
end

function WebSocketServer:GetNumConnectedClients()
	return tonumber(uws.bindings.uws_webserver_get_client_count(self.nativeHandle))
end

-- These should trigger WEBSOCKET_BACKPRESSURE_* events and check uws_buffered_amount (coming soon™)
function WebSocketServer:BroadcastTextMessage(message)
	return uws.bindings.uws_webserver_broadcast_text(self.nativeHandle, message, #message)
end

function WebSocketServer:BroadcastBinaryMessage(message)
	return uws.bindings.uws_webserver_broadcast_binary(self.nativeHandle, message, #message)
end

function WebSocketServer:BroadcastCompressedTextMessage(message)
	return uws.bindings.uws_webserver_broadcast_compressed(self.nativeHandle, message, #message)
end

function WebSocketServer:SendTextMessageToClient(message, clientID)
	return uws.bindings.uws_webserver_send_text(self.nativeHandle, message, #message, clientID)
end

function WebSocketServer:SendBinaryMessageToClient(message, clientID)
	return uws.bindings.uws_webserver_send_binary(self.nativeHandle, message, #message, clientID)
end

function WebSocketServer:SendCompressedTextMessageToClient(message, clientID)
	return uws.bindings.uws_webserver_send_compressed(self.nativeHandle, message, #message, clientID)
end

function WebSocketServer:OnEvent(eventName, payload)
	local eventHandler = self[eventName]

	if eventHandler then
		eventHandler(self, eventName, payload)
	else
		self:UNKNOWN_OR_INVALID_WEBSOCKET_EVENT(eventName, payload)
	end
end

function WebSocketServer:ASYNC_POLLING_UPDATE() end

function WebSocketServer:WEBSOCKET_SERVER_STARTED(event, payload)
	print("[WebSocketServer] WEBSOCKET_SERVER_STARTED")
end

function WebSocketServer:WEBSOCKET_SERVER_STOPPED(event, payload)
	print("[WebSocketServer] WEBSOCKET_SERVER_STOPPED")
end

function WebSocketServer:WEBSOCKET_CONNECTION_ESTABLISHED(event, payload)
	print("[WebSocketServer] WEBSOCKET_CONNECTION_ESTABLISHED", payload.clientID)
end

function WebSocketServer:WEBSOCKET_CONNECTION_CLOSED(event, payload)
	print("[WebSocketServer] WEBSOCKET_CONNECTION_CLOSED", payload.clientID)
end

function WebSocketServer:WEBSOCKET_MESSAGE_RECEIVED(event, payload)
	print("[WebSocketServer] WEBSOCKET_MESSAGE_RECEIVED", #payload.message, payload.clientID)
end

function WebSocketServer:UNKNOWN_OR_INVALID_WEBSOCKET_EVENT(event, payload)
	print("[WebSocketServer] UNKNOWN_OR_INVALID_WEBSOCKET_EVENT")

	dump(payload)
	error(format("Encountered unknown WebSocket event %s (this should never happen)", event), 0)
end

return WebSocketServer
