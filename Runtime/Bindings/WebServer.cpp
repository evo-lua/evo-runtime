#include <macros.hpp>

#include "WebServer.hpp"

#include "uws_ffi.hpp"

#include <iostream>
#include <iomanip>
#include <sstream>

WebServer::WebServer() {
	// TLS setup and managing creation options should be handled here, but it's not yet implemented
}

void WebServer::StartListening(int port) {
	m_uwsAppHandle.listen(port, [this, port](auto* listenSocket) {
		if(!listenSocket) {
			std::cerr << "[" << FROM_HERE << "] "
					  << "Failed to listen on port " << port << std::endl;
			return;
		}

		UWS_DEBUG("Now listening on port ", port);
		m_usListenSocket = listenSocket;

		m_deferredEventsQueue.emplace(DeferredEvent::Type::LISTEN, "SERVER", std::to_string(port));
	});
}

void WebServer::StopListening() {
	UWS_DEBUG("Shutting down ...");

	if(m_usListenSocket == nullptr) {
		std::cerr << "[" << FROM_HERE << "] "
				  << "Failed shutdown: m_usListenSocket is nullptr" << std::endl;
		return;
	}

	DisconnectAllClients();
	AbortAllConnections();

	us_listen_socket_close(false, m_usListenSocket);
	m_usListenSocket = nullptr;

	UWS_DEBUG("Shutdown complete");
	m_deferredEventsQueue.emplace(DeferredEvent::Type::SHUTDOWN, "SERVER", "Going Away");
}

size_t WebServer::GetMaxAllowedPayloadSize() {
	return m_maxPayloadSize;
}

void WebServer::AddWebSocketRoute(std::string route) {
	uWS::App::WebSocketBehavior<PerSocketData> wsBehavior;

	wsBehavior.compression = m_compressionMode;
	wsBehavior.maxPayloadLength = m_maxPayloadSize;
	wsBehavior.idleTimeout = m_idleTimeoutInSeconds;
	wsBehavior.maxBackpressure = m_maxBackpressureLimit;
	wsBehavior.closeOnBackpressureLimit = m_closeOnBackpressureLimit;
	wsBehavior.resetIdleTimeoutOnSend = m_resetIdleTimeoutOnSend;
	wsBehavior.sendPingsAutomatically = m_sendPingsAutomatically;
	wsBehavior.maxLifetime = m_maxSocketLifetimeInMinutes;

	wsBehavior.upgrade = [this](auto* response, auto* request, auto* socketContext) {
		OnUpgrade(response, request, socketContext);
	};

	wsBehavior.open = [this](auto* websocket) {
		OnWebSocketOpen(websocket);
	};

	wsBehavior.message = [this](auto* websocket, std::string_view message, uWS::OpCode opCode) {
		OnWebSocketMessage(websocket, message, opCode);
	};

	wsBehavior.close = [this](auto* websocket, int code, std::string_view message) {
		OnWebSocketClose(websocket, code, message);
	};

	// Should probably store the route, allow removing it, and more (all saved for later)
	m_uwsAppHandle.ws<PerSocketData>(route, std::move(wsBehavior));

	UWS_DEBUG("WebSocket route registered: ", route);
}

void WebServer::AddGetRoute(std::string route) {
	m_uwsAppHandle.get(route, [this, route](auto* response, auto* request) {
		CreateRouteHandler("GET", route, response, request);
	});

	UWS_DEBUG("GET route registered: ", route);
}

void WebServer::AddPostRoute(std::string route) {
	m_uwsAppHandle.post(route, [this, route](auto* response, auto* request) {
		CreateRouteHandler("POST", route, response, request);
	});

	UWS_DEBUG("POST route registered: ", route);
}

void WebServer::AddOptionsRoute(std::string route) {
	m_uwsAppHandle.options(route, [this, route](auto* response, auto* request) {
		CreateRouteHandler("OPTIONS", route, response, request);
	});

	UWS_DEBUG("OPTIONS route registered: ", route);
}

void WebServer::AddDeleteRoute(std::string route) {
	m_uwsAppHandle.del(route, [this, route](auto* response, auto* request) {
		CreateRouteHandler("DELETE", route, response, request);
	});

	UWS_DEBUG("DELETE route registered: ", route);
}

void WebServer::AddPatchRoute(std::string route) {
	m_uwsAppHandle.patch(route, [this, route](auto* response, auto* request) {
		CreateRouteHandler("PATCH", route, response, request);
	});

	UWS_DEBUG("PATCH route registered: ", route);
}

void WebServer::AddPutRoute(std::string route) {
	m_uwsAppHandle.put(route, [this, route](auto* response, auto* request) {
		CreateRouteHandler("PUT", route, response, request);
	});

	UWS_DEBUG("PUT route registered: ", route);
}

void WebServer::AddHeadRoute(std::string route) {
	m_uwsAppHandle.head(route, [this, route](auto* response, auto* request) {
		CreateRouteHandler("HEAD", route, response, request);
	});

	UWS_DEBUG("HEAD route registered: ", route);
}

void WebServer::AddAnyRoute(std::string route) {
	m_uwsAppHandle.any(route, [this, route](auto* response, auto* request) {
		CreateRouteHandler("ANY", route, response, request);
	});

	UWS_DEBUG("ANY route registered: ", route);
}

void WebServer::OnUpgrade(auto* response, auto* request, auto* socketContext) {
	uuid_rfc_string_t clientID;
	uuid_create_mt19937(&clientID);

	UWS_DEBUG("Upgrade request received from client ", clientID);
	PerSocketData perSocketData { .clientID = std::string(clientID) };

	response->template upgrade<PerSocketData>(std::move(perSocketData), request->getHeader("sec-websocket-key"), request->getHeader("sec-websocket-protocol"), request->getHeader("sec-websocket-extensions"), socketContext);
}

void WebServer::OnWebSocketOpen(auto* websocket) {
	std::string clientID = websocket->getUserData()->clientID;

	UWS_DEBUG("Client connected: ", clientID);

	m_deferredEventsQueue.emplace(DeferredEvent::Type::OPEN, clientID, "");

	PerSocketData* perSocketData = websocket->getUserData();
	m_websocketClientsMap[perSocketData->clientID] = websocket;
}

void WebServer::OnWebSocketClose(auto* websocket, int code, std::string_view message) {
	std::string clientID = websocket->getUserData()->clientID;

	UWS_DEBUG("Client ", clientID, " disconnected: ", message);

	m_deferredEventsQueue.emplace(DeferredEvent::Type::CLOSE, clientID, std::string(message));

	// Since the server owns the map, we can't safely delete the entry here
	m_websocketClientsMap[clientID] = nullptr;
}

void WebServer::OnWebSocketMessage(auto* websocket, std::string_view message, uWS::OpCode opCode) {
	std::string clientID = websocket->getUserData()->clientID;

	UWS_DEBUG("Received ", uws_ffi::opCodeToString(opCode), " message of length ", message.length(), " from client ", clientID);
	m_deferredEventsQueue.emplace(DeferredEvent::Type::MESSAGE, clientID, std::string(message));

	if(!m_isEchoServer) return;

	bool shouldCompressMessage = false;
	websocket->send(message, opCode, shouldCompressMessage);
}

void WebServer::OnRequest(std::string requestID, auto* response, auto* request, std::string route) {
	UWS_DEBUG("HTTP request started: ", requestID, " (Headers complete)");
	m_deferredEventsQueue.emplace(DeferredEvent::Type::HTTP_START, requestID, "");

	StoreRequestDetails(requestID, response, request, route);
	SetCallbackHandlers(requestID, response, request);
}

void WebServer::OnChunkReceived(std::string requestID, std::string_view chunk) {
	UWS_DEBUG("HTTP request updated: ", requestID, " (", chunk.length(), " bytes received)");
	m_deferredEventsQueue.emplace(DeferredEvent::Type::HTTP_DATA, requestID, std::string(chunk));
}

void WebServer::OnLastChunkReceived(std::string requestID, std::string_view chunk) {
	UWS_DEBUG("HTTP request finished: ", requestID, " (", chunk.length(), " bytes received)");
	m_deferredEventsQueue.emplace(DeferredEvent::Type::HTTP_END, requestID, std::string(chunk));
}

void WebServer::OnConnectionWritable(std::string requestID, long unsigned int offset) {
	UWS_DEBUG("HTTP connection writable: ", requestID, " (offset is now ", offset, ")");

	m_deferredEventsQueue.emplace(DeferredEvent::Type::HTTP_WRITABLE, requestID, "");
}

void WebServer::OnConnectionAborted(std::string requestID) {
	UWS_DEBUG("HTTP connection aborted: ", requestID, " (Peer has gone away)");

	m_deferredEventsQueue.emplace(DeferredEvent::Type::HTTP_ABORT, requestID, "");
	m_httpClientsMap.erase(requestID);
}

size_t WebServer::GetNumConnectedClients() {
	// Also includes faded clients: PurgeFadedClients() can remove them before calling this if needed
	return m_websocketClientsMap.size();
}

WebSocket* WebServer::FindClientByID(const std::string& clientID) {
	const auto iterator = m_websocketClientsMap.find(clientID);

	bool isClientKnown = (iterator != m_websocketClientsMap.end());
	if(!isClientKnown) return nullptr;

	return iterator->second;
}

void WebServer::DisconnectAllClients() {
	UWS_DEBUG("Disconnecting all clients ...");

	for(const auto& [clientID, websocket] : m_websocketClientsMap) {
		bool isFadedClient = (websocket == nullptr);
		if(isFadedClient) continue;

		websocket->close();
	}

	m_websocketClientsMap.clear();
}

size_t WebServer::PurgeFadedClients() {
	// Entries can't be deleted from within the uws callback as this interferes with the shutdown process (server instance owns the map)
	// Separating the actual cleanup step also enables the Lua runtime to control it more easily and retrieve some basic metrics
	size_t numPurgedClients = 0;
	for(auto iterator = m_websocketClientsMap.begin(); iterator != m_websocketClientsMap.end();) {
		bool shouldPurgeClient = (iterator->second == nullptr);

		if(shouldPurgeClient) {
			UWS_DEBUG("Purging faded client ", iterator->first);
			iterator = m_websocketClientsMap.erase(iterator);
			numPurgedClients++;
		} else iterator++;
	}

	return numPurgedClients;
}

size_t WebServer::AbortAllConnections() {

	UWS_DEBUG("Aborting pending requests ...");

	size_t numAbortedConnections = 0;

	for(const auto& [requestID, httpMessageData] : m_httpClientsMap) {

		httpMessageData.response->writeStatus("503 Service Unavailable");
		httpMessageData.response->writeHeader("Content-Type", "text/plain");
		httpMessageData.response->end("Service Unavailable: Server shutting down");

		UWS_DEBUG("HTTP request aborted: ", requestID, " (Server shutting down)");

		numAbortedConnections++;
	}

	m_httpClientsMap.clear();

	return numAbortedConnections;
}

WebSocket::SendStatus WebServer::BroadcastTextMessage(const std::string& message) {
	WebSocket::SendStatus status = WebSocket::SUCCESS;

	for(const auto& [clientID, websocket] : m_websocketClientsMap) {

		if(!websocket) continue; // Skip faded clients

		WebSocket::SendStatus currentStatus = websocket->send(message, uWS::OpCode::TEXT);
		if(currentStatus == WebSocket::DROPPED) status = WebSocket::DROPPED;
	}

	return status;
}

WebSocket::SendStatus WebServer::BroadcastBinaryMessage(const std::string& message) {
	WebSocket::SendStatus status = WebSocket::SUCCESS;

	for(const auto& [clientID, websocket] : m_websocketClientsMap) {

		if(!websocket) continue; // Skip faded clients

		WebSocket::SendStatus currentStatus = websocket->send(message, uWS::OpCode::BINARY);
		if(currentStatus == WebSocket::DROPPED) status = WebSocket::DROPPED;
	}

	return status;
}

WebSocket::SendStatus WebServer::BroadcastCompressedTextMessage(const std::string& message) {
	WebSocket::SendStatus status = WebSocket::SUCCESS;

	for(const auto& [clientID, websocket] : m_websocketClientsMap) {

		if(!websocket) continue; // Skip faded clients

		WebSocket::SendStatus currentStatus = websocket->send(message, uWS::OpCode::TEXT, true /* compress */);
		if(currentStatus == WebSocket::DROPPED) status = WebSocket::DROPPED;
	}

	return status;
}

WebSocket::SendStatus WebServer::SendTextMessageToClient(const std::string& message, const std::string& clientID) {
	auto* websocket = FindClientByID(clientID);
	if(!websocket) return WebSocket::DROPPED;

	return websocket->send(message, uWS::OpCode::TEXT);
}

WebSocket::SendStatus WebServer::SendBinaryMessageToClient(const std::string& message, const std::string& clientID) {
	auto* websocket = FindClientByID(clientID);
	if(!websocket) return WebSocket::DROPPED;

	return websocket->send(message, uWS::OpCode::BINARY);
}

WebSocket::SendStatus WebServer::SendCompressedTextMessageToClient(const std::string& message, const std::string& clientID) {
	auto* websocket = FindClientByID(clientID);
	if(!websocket) return WebSocket::DROPPED;

	return websocket->send(message, uWS::OpCode::TEXT, true /* compress */);
}

HttpSendStatus WebServer::WriteResponse(const std::string& requestID, const std::string& data) {
	auto iterator = m_httpClientsMap.find(requestID);
	if(iterator == m_httpClientsMap.end()) {
		return HttpSendStatus::None;
	}

	auto& response = iterator->second.response;
	bool success = response->write(data);

	if(!success) return HttpSendStatus::None;
	return HttpSendStatus::SentAndEnded;
}

HttpSendStatus WebServer::EndResponse(const std::string& requestID, const std::string& data) {
	UWS_DEBUG("HTTP request finished: ", requestID, " (Sending response with ", data.size(), " bytes)");

	auto iterator = m_httpClientsMap.find(requestID);
	if(iterator == m_httpClientsMap.end()) {
		return HttpSendStatus::None;
	}

	auto& response = iterator->second.response;

	response->end(data);
	m_httpClientsMap.erase(iterator);
	return HttpSendStatus::SentAndEnded;
}

HttpSendStatus WebServer::TryEndResponse(const std::string& requestID, const std::string& data) {
	auto iterator = m_httpClientsMap.find(requestID);
	if(iterator == m_httpClientsMap.end()) {
		return HttpSendStatus::None;
	}

	auto& response = iterator->second.response;
	auto result = response->tryEnd(data);
	if(result.second) {
		m_httpClientsMap.erase(iterator);
	}

	HttpSendStatus encodedResult = static_cast<HttpSendStatus>((result.first ? 1 : 0) | (result.second ? 2 : 0));
	return encodedResult;
}

bool WebServer::WriteResponseStatus(const std::string& requestID, const std::string& statusCodeAndText) {
	auto iterator = m_httpClientsMap.find(requestID);
	if(iterator == m_httpClientsMap.end()) {
		return false;
	}

	auto& response = iterator->second.response;
	return response->writeStatus(statusCodeAndText);
}

bool WebServer::HasRequest(std::string requestID) {
	return (m_httpClientsMap.find(requestID) != m_httpClientsMap.end());
}

bool WebServer::GetRequestMethod(const std::string& requestID, char* buffer, size_t bufferSize) {
	auto httpMessageDataIter = m_httpClientsMap.find(requestID);
	if(httpMessageDataIter != m_httpClientsMap.end()) {
		strncpy(buffer, httpMessageDataIter->second.requestDetails.method.c_str(), bufferSize - 1);
		buffer[bufferSize - 1] = '\0';
		return true;
	}
	return false;
}

bool WebServer::GetRequestURL(const std::string& requestID, char* buffer, size_t bufferSize) {
	auto httpMessageDataIter = m_httpClientsMap.find(requestID);
	if(httpMessageDataIter != m_httpClientsMap.end()) {
		strncpy(buffer, httpMessageDataIter->second.requestDetails.url.c_str(), bufferSize - 1);
		buffer[bufferSize - 1] = '\0';
		return true;
	}
	return false;
}

bool WebServer::GetRequestQuery(const std::string& requestID, char* buffer, size_t bufferSize) {
	auto httpMessageDataIter = m_httpClientsMap.find(requestID);
	if(httpMessageDataIter != m_httpClientsMap.end()) {
		strncpy(buffer, httpMessageDataIter->second.requestDetails.query.c_str(), bufferSize - 1);
		buffer[bufferSize - 1] = '\0';
		return true;
	}
	return false;
}

bool WebServer::GetRequestHeader(const std::string& requestID, const std::string& headerName, char* buffer, size_t bufferSize) {
	auto httpMessageDataIter = m_httpClientsMap.find(requestID);
	if(httpMessageDataIter != m_httpClientsMap.end()) {
		auto headersIter = httpMessageDataIter->second.requestDetails.headers.find(headerName);
		if(headersIter != httpMessageDataIter->second.requestDetails.headers.end()) {
			strncpy(buffer, headersIter->second.c_str(), bufferSize - 1);
			buffer[bufferSize - 1] = '\0';
			return true;
		}
	}
	return false;
}

bool WebServer::GetRequestEndpoint(const std::string& requestID, char* buffer, size_t bufferSize) {
	auto httpMessageDataIter = m_httpClientsMap.find(requestID);
	if(httpMessageDataIter != m_httpClientsMap.end()) {
		strncpy(buffer, httpMessageDataIter->second.requestDetails.endpoint.c_str(), bufferSize - 1);
		buffer[bufferSize - 1] = '\0';
		return true;
	}
	return false;
}

bool WebServer::GetSerializedRequestHeaders(const std::string& requestID, char* buffer, size_t bufferSize) {
	auto httpMessageDataIter = m_httpClientsMap.find(requestID);
	if(httpMessageDataIter != m_httpClientsMap.end()) {
		std::stringstream ss;
		for(const auto& header : httpMessageDataIter->second.requestDetails.headers) {
			ss << header.first << ": " << header.second << "\r\n";
		}
		std::string serializedHeaders = ss.str();

		if(serializedHeaders.size() + 1 > bufferSize) {
			// Not enough space in the buffer to store the serialized headers.
			return false;
		}

		strncpy(buffer, serializedHeaders.c_str(), bufferSize - 1);
		buffer[bufferSize - 1] = '\0';
		return true;
	}
	return false;
}

size_t WebServer::GetNumDeferredEvents() {
	return m_deferredEventsQueue.size();
}

bool WebServer::HasDeferredEvents() {
	return !m_deferredEventsQueue.empty();
}

void WebServer::GetNextDeferredEvent(uws_webserver_event_t* preallocatedEventBuffer) {
	if(preallocatedEventBuffer == nullptr) {
		std::cerr << "[" << FROM_HERE << "] "
				  << "Failed to GetNextDeferredEvent: Missing preallocated event buffer" << std::endl;
		return;
	}

	if(preallocatedEventBuffer->payload == nullptr) {
		std::cerr << "[" << FROM_HERE << "] "
				  << "Failed to GetNextDeferredEvent: Uninitialized payload buffer" << std::endl;
		return;
	}

	if(m_deferredEventsQueue.empty()) {
		std::cerr << "[" << FROM_HERE << "] "
				  << "Failed to GetNextDeferredEvent: Queue is empty" << std::endl;
		return;
	}

	DeferredEvent event = m_deferredEventsQueue.front();

	// LuaJIT is expected to manage the lifetime of the cdata, so we don't have to
	preallocatedEventBuffer->type = static_cast<int>(event.type);

	strncpy(preallocatedEventBuffer->clientID, event.clientID.c_str(), sizeof(preallocatedEventBuffer->clientID));
	preallocatedEventBuffer->clientID[sizeof(preallocatedEventBuffer->clientID) - 1] = '\0';

	// If the preallocated buffer is too small, there's only so much we can do here
	size_t payloadLength = std::min(m_maxPayloadSize - 1, event.payload.size());
	if(payloadLength < event.payload.size())
		std::cerr << "[" << FROM_HERE << "] "
				  << "Warning: Payload buffer too small (data may be truncated)" << std::endl;

	memcpy(preallocatedEventBuffer->payload, event.payload.c_str(), payloadLength);
	preallocatedEventBuffer->payload[payloadLength] = '\0';
	preallocatedEventBuffer->payload_size = payloadLength;

	m_deferredEventsQueue.pop();
}

void WebServer::SetEchoMode(bool enabledFlag) {
	UWS_DEBUG("Echo server mode is now ", (enabledFlag ? "ON" : "OFF"));
	m_isEchoServer = enabledFlag;
}

void WebServer::DumpConfiguredSettings() {
	std::cout << std::left << std::setw(32) << "  Max. Payload Size:" << m_maxPayloadSize / 1024.0 << " KB" << std::endl;
	std::cout << std::left << std::setw(32) << "  Max. Backpressure Limit:" << m_maxBackpressureLimit / 1024.0 << " KB" << std::endl;
	std::cout << std::left << std::setw(32) << "  Idle Timeout:" << m_idleTimeoutInSeconds << " seconds" << std::endl;
	std::cout << std::left << std::setw(32) << "  Send Pings Automatically:" << (m_sendPingsAutomatically ? "YES" : "NO") << std::endl;
	std::cout << std::left << std::setw(32) << "  Close on Backpressure:" << (m_closeOnBackpressureLimit ? "YES" : "NO") << std::endl;
	std::cout << std::left << std::setw(32) << "  Reset Idle Timeout on Send:" << (m_resetIdleTimeoutOnSend ? "YES" : "NO") << std::endl;
	std::cout << std::left << std::setw(32) << "  Compression Mode:" << uws_ffi::compressOptionsToString(m_compressionMode) << std::endl;
	std::cout << std::left << std::setw(32) << "  Max. Socket Lifetime:" << m_maxSocketLifetimeInMinutes << " minutes" << std::endl;
}

void WebServer::DumpDeferredEvents() {
	std::cout << "DeferredEvent queue size: " << m_deferredEventsQueue.size() << std::endl;

	// Creating a temporary queue is messy at best, but this is only for debugging anyway
	std::queue<DeferredEvent> tempQueue;

	while(!m_deferredEventsQueue.empty()) {
		const DeferredEvent& event = m_deferredEventsQueue.front();

		std::cout << "DeferredEvent type: " << event.type << std::endl;
		std::cout << "DeferredEvent clientID: " << event.clientID << std::endl;
		std::cout << "DeferredEvent payload: " << event.payload << std::endl;
		std::cout << std::endl;

		tempQueue.push(event);
		m_deferredEventsQueue.pop();
	}

	m_deferredEventsQueue = std::move(tempQueue);
}

inline std::string WebServer::GetCurrentTimeAsText() {
	auto now = std::chrono::system_clock::now();
	auto currentTimeSinceEpoch = std::chrono::system_clock::to_time_t(now);
	std::string currentTimeString = std::ctime(&currentTimeSinceEpoch);
	currentTimeString.pop_back(); // Removes the redundant \n

	return currentTimeString;
}

inline void WebServer::CreateRouteHandler(std::string method, std::string route, auto* response, auto* request) {
	uuid_rfc_string_t requestID;
	uuid_create_mt19937(&requestID);

	UWS_DEBUG(method, " request ", requestID, " received from ", response->getRemoteAddressAsText(), " on ", GetCurrentTimeAsText(), " for URL ", request->getUrl());

	OnRequest(requestID, response, request, route);
}

inline bool WebServer::StoreRequestDetails(std::string requestID, auto* response, auto* request, std::string route) {
	bool hasAnotherRequestWithThisID = (m_httpClientsMap.find(requestID) != m_httpClientsMap.end());
	if(hasAnotherRequestWithThisID) { // Extremely unlikely, but better safe than sorry?
		std::cerr << "[" << FROM_HERE << "] "
				  << "Request ID " << requestID << " is already in use" << std::endl;
		return false;
	}

	// The request may be deleted before LuaJIT gets to query it, so we must copy what we need for future reference
	HttpRequestDetails requestDetails;
	requestDetails.method = request->getMethod();
	requestDetails.url = request->getUrl();
	requestDetails.query = request->getQuery();
	requestDetails.endpoint = route;

	for(const auto& [key, value] : *request) {
		requestDetails.headers[std::string(key)] = std::string(value);
	}

	std::shared_ptr<HttpResponse> sharedResponsePointer(response, [](HttpResponse*) {}); // Empty deleter because uws owns the data
	m_httpClientsMap.emplace(requestID, HttpMessageData { requestDetails, sharedResponsePointer });

	return true;
}

inline void WebServer::SetCallbackHandlers(std::string requestID, auto* response, auto* request) {
	response->onData([this, requestID](const std::string_view& chunk, bool isLast) {
		if(isLast) OnLastChunkReceived(requestID, chunk);
		else OnChunkReceived(requestID, chunk);
	});

	response->onAborted([this, requestID]() {
		OnConnectionAborted(requestID);
	});

	response->onWritable([this, requestID](long unsigned int offset) {
		OnConnectionWritable(requestID, offset);
		// Always continue to poll for writability, for now - there's probably no way to control this from LuaJIT?
		return true;
	});
}