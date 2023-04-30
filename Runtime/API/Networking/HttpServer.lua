local ffi = require("ffi")
local uv = require("uv")
local uws = require("uws")

local validation = require("validation")
local validateString = validation.validateString

local tonumber = tonumber

local HttpServer = {
	DEFAULT_PORT = 9001,
	UWS_ROUTING_APIS = {
		GET = uws.bindings.uws_webserver_add_get_route,
		POST = uws.bindings.uws_webserver_add_post_route,
		OPTIONS = uws.bindings.uws_webserver_add_options_route,
		DELETE = uws.bindings.uws_webserver_add_delete_route,
		PATCH = uws.bindings.uws_webserver_add_patch_route,
		PUT = uws.bindings.uws_webserver_add_put_route,
		HEAD = uws.bindings.uws_webserver_add_head_route,
		ANY = uws.bindings.uws_webserver_add_any_route, -- Wildcard (default handler)
	},
}

function HttpServer:Construct()
	local instance = {
		pollingUpdateTimeInMilliseconds = 16,
		pollingUpdateTimer = uv.new_timer(),
		nativeHandle = uws.bindings.uws_webserver_create(),
		registeredRoutes = {
			GET = {},
			POST = {},
			OPTIONS = {},
			DELETE = {},
			PATCH = {},
			PUT = {},
			HEAD = {},
			ANY = {},
		},
	}

	local maxPayloadSize = uws.bindings.uws_webserver_payload_size(instance.nativeHandle)
	instance.maxPayloadSize = tonumber(maxPayloadSize)

	local preallocatedRequestDataBuffer = ffi.new("char[?]", instance.maxPayloadSize + 1)
	instance.preallocatedRequestDataBuffer = preallocatedRequestDataBuffer

	local preallocatedEventBuffer = ffi.new("uws_webserver_event_t")
	local payload = ffi.new("char[?]", instance.maxPayloadSize + 1)
	preallocatedEventBuffer.payload = payload

	--  Since cdata fields aren't GC anchors, manually keep the payload buffer alive
	instance.preallocatedPayloadBuffer = payload
	instance.preallocatedEventBuffer = preallocatedEventBuffer

	setmetatable(instance, self)

	return instance
end

HttpServer.__index = HttpServer
HttpServer.__call = HttpServer.Construct
HttpServer.__gc = function(self)
	uws.bindings.uws_webserver_delete(self.nativeHandle)
end

setmetatable(HttpServer, HttpServer)

function HttpServer:StartListening(port)
	port = port or HttpServer.DEFAULT_PORT

	uws.bindings.uws_webserver_listen(self.nativeHandle, port)

	self.pollingUpdateTimer:start(0, self.pollingUpdateTimeInMilliseconds, function()
		self:ProcessDeferredEvents()
		self:ASYNC_POLLING_UPDATE()
	end)
end

function HttpServer:StopListening()
	uws.bindings.uws_webserver_stop(self.nativeHandle)

	--  Make sure to flush all remaining events and process any leftovers to shut down cleanly
	self.pollingUpdateTimer:stop()
	self:ProcessDeferredEvents()
	self:ASYNC_POLLING_UPDATE()
end

function HttpServer:ProcessDeferredEvents()
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

function HttpServer:AddRoute(route, method)
	validateString(route, "route")

	method = method or "ANY"

	validateString(method, "method")

	printf("[HttpServer] Adding route %s for method %s", route, method)

	if not HttpServer.UWS_ROUTING_APIS[method] then
		error("Failed to add HTTP route (invalid method: " .. method .. ")", 0)
	end

	if self.registeredRoutes[method] and self.registeredRoutes[method][route] then
		error("Failed to add HTTP route (already registered: " .. route .. ")", 0)
	end

	HttpServer.UWS_ROUTING_APIS[method](self.nativeHandle, route)

	self.registeredRoutes[method][route] = true
end

function HttpServer:GetRegisteredRoutes(method)
	return self.registeredRoutes[method]
end

function HttpServer:WriteResponse(requestID, message)
	return uws.bindings.uws_webserver_response_write(self.nativeHandle, requestID, message, #message)
end

function HttpServer:SendResponse(requestID, message)
	return uws.bindings.uws_webserver_response_end(self.nativeHandle, requestID, message, #message)
end

function HttpServer:StreamResponse(requestID, message)
	return uws.bindings.uws_webserver_response_try_end(self.nativeHandle, requestID, message, #message)
end

function HttpServer:WriteStatus(requestID, statusCodeAndText)
	return uws.bindings.uws_webserver_response_status(self.nativeHandle, requestID, statusCodeAndText)
end

function HttpServer:GetRequestEndpoint(requestID)
	local cdata = self.preallocatedRequestDataBuffer

	local success =
		uws.bindings.uws_webserver_request_endpoint(self.nativeHandle, requestID, cdata, self.maxPayloadSize)
	if not success then
		return
	end

	return ffi.string(cdata)
end

-- Potentially wasteful, but let's wait and see if it will become a problem
local function deserializeHeaders(serializedHeaders)
	if not serializedHeaders then
		return
	end

	local headers = {}

	for line in serializedHeaders:gmatch("[^\r\n]+") do
		local key, value = line:match("([^:]+):%s*(.+)")
		if key and value then
			headers[key] = value
		end
	end

	return headers
end

function HttpServer:GetRequestDetails(requestID)
	local serializedHeaders = self:GetRequestHeaders(requestID)
	local deserializedHeaders = deserializeHeaders(serializedHeaders)

	if not self:HasRequestDetails(requestID) then
		return
	end

	local requestDetails = {
		method = self:GetRequestMethod(requestID),
		url = self:GetRequestURL(requestID),
		query = self:GetRequestQuery(requestID),
		endpoint = self:GetRequestEndpoint(requestID),
		headers = deserializedHeaders,
	}
	return requestDetails
end

function HttpServer:HasRequestDetails(requestID)
	return uws.bindings.uws_webserver_has_request(self.nativeHandle, requestID)
end

function HttpServer:GetRequestMethod(requestID)
	local cdata = self.preallocatedRequestDataBuffer

	local success = uws.bindings.uws_webserver_request_method(self.nativeHandle, requestID, cdata, self.maxPayloadSize)
	if not success then
		return
	end

	return string.upper(ffi.string(cdata))
end

function HttpServer:GetRequestURL(requestID)
	local cdata = self.preallocatedRequestDataBuffer

	local success = uws.bindings.uws_webserver_request_url(self.nativeHandle, requestID, cdata, self.maxPayloadSize)
	if not success then
		return
	end

	return ffi.string(cdata)
end

function HttpServer:GetRequestQuery(requestID)
	local cdata = self.preallocatedRequestDataBuffer

	local success = uws.bindings.uws_webserver_request_query(self.nativeHandle, requestID, cdata, self.maxPayloadSize)
	if not success then
		return
	end

	return ffi.string(cdata)
end

function HttpServer:GetRequestHeaders(requestID)
	local cdata = self.preallocatedRequestDataBuffer

	-- Worst case: The entire message will be filled up with headers (unlikely)
	local success =
		uws.bindings.uws_webserver_request_serialized_headers(self.nativeHandle, requestID, cdata, self.maxPayloadSize)
	if not success then
		return
	end

	return ffi.string(cdata)
end

function HttpServer:GetRequestHeader(requestID, headerName)
	local cdata = self.preallocatedRequestDataBuffer

	local success = uws.bindings.uws_webserver_request_header_value(
		self.nativeHandle,
		requestID,
		cdata,
		headerName,
		self.maxPayloadSize
	)
	if not success then
		return
	end

	return ffi.string(cdata)
end

function HttpServer:OnEvent(eventName, payload)
	local eventHandler = self[eventName]

	if eventHandler then
		eventHandler(self, eventName, payload)
	else
		self:UNKNOWN_OR_INVALID_WEBSERVER_EVENT(eventName, payload)
	end
end

function HttpServer:ASYNC_POLLING_UPDATE() end

function HttpServer:SERVER_STARTED_LISTENING(event, payload)
	print("[HttpServer] SERVER_STARTED_LISTENING")
end

function HttpServer:SERVER_STOPPED_LISTENING(event, payload)
	print("[HttpServer] SERVER_STOPPED_LISTENING")
end

function HttpServer:HTTP_REQUEST_STARTED(event, payload)
	print("[HttpServer] HTTP_REQUEST_STARTED", payload.clientID)
end

function HttpServer:HTTP_DATA_RECEIVED(event, payload)
	print("[HttpServer] HTTP_DATA_RECEIVED", payload.clientID)
end

function HttpServer:HTTP_REQUEST_FINISHED(event, payload)
	print("[HttpServer] HTTP_REQUEST_FINISHED", payload.clientID)
end

function HttpServer:HTTP_CONNECTION_ABORTED(event, payload)
	print("[HttpServer] HTTP_CONNECTION_ABORTED", payload.clientID)
end

function HttpServer:HTTP_CONNECTION_WRITABLE(event, payload)
	print("[HttpServer] HTTP_CONNECTION_WRITABLE", payload.clientID)
end

function HttpServer:UNKNOWN_OR_INVALID_WEBSERVER_EVENT(event, payload)
	print("[HttpServer] UNKNOWN_OR_INVALID_WEBSERVER_EVENT")

	dump(payload)
	error(format("Encountered unknown WebSocket event %s (this should never happen)", event), 0)
end

return HttpServer
