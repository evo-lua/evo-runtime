#include "WebServer.hpp"

#include "uws_ffi.hpp"

#include <iostream>
#include <iomanip>

WebServer::WebServer() {
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
		this->OnUpgrade(response, request, socketContext);
	};

	wsBehavior.open = [this](auto* websocket) {
		this->OnWebSocketOpen(websocket);
	};

	wsBehavior.message = [this](auto* websocket, std::string_view message, uWS::OpCode opCode) {
		this->OnWebSocketMessage(websocket, message, opCode);
	};

	wsBehavior.close = [this](auto* websocket, int code, std::string_view message) {
		this->OnWebSocketClose(websocket, code, message);
	};

	// This default catch-all route should likely be made configurable, but for now it's sufficient
	AddWebSocketRoute("/*", std::move(wsBehavior));
}

void WebServer::StartListening(int port) {
	m_uwsAppHandle.listen(port, [this, port](auto* listenSocket) {
		if(!listenSocket)
			return UWS_DEBUG("Failed to listen on port ", port);

		UWS_DEBUG("Now listening on port ", port);
		this->m_usListenSocket = listenSocket;

		m_deferredEventsQueue.emplace(DeferredEvent::Type::LISTEN, "SERVER", std::to_string(port));
	});
}

void WebServer::StopListening() {
	UWS_DEBUG("Shutting down ...");

	if(this->m_usListenSocket == nullptr) {
		std::cerr << "Failed shutdown: m_usListenSocket is nullptr" << std::endl;
		return;
	}

	DisconnectAllClients();

	us_listen_socket_close(false, this->m_usListenSocket);
	this->m_usListenSocket = nullptr;

	UWS_DEBUG("Shutdown complete");
	m_deferredEventsQueue.emplace(DeferredEvent::Type::SHUTDOWN, "SERVER", "Going Away");
}

size_t WebServer::GetMaxAllowedPayloadSize() {
	return m_maxPayloadSize;
}

void WebServer::AddWebSocketRoute(std::string route, uWS::App::WebSocketBehavior<PerSocketData>&& wsBehavior) {
	// Should probably store the route, allow removing it, and more (all saved for later)
	m_uwsAppHandle.ws<PerSocketData>(route, std::move(wsBehavior));
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

size_t WebServer::GetNumDeferredEvents() {
	return m_deferredEventsQueue.size();
}

bool WebServer::HasDeferredEvents() {
	return !m_deferredEventsQueue.empty();
}

void WebServer::GetNextDeferredEvent(uws_webserver_event_t* preallocatedEventBuffer) {
	if(preallocatedEventBuffer == nullptr) {
		std::cerr << "Failed to GetNextDeferredEvent: Missing preallocated event buffer" << std::endl;
		return;
	}

	if(preallocatedEventBuffer->payload == nullptr) {
		std::cerr << "Failed to GetNextDeferredEvent: Uninitialized payload buffer" << std::endl;
		return;
	}

	if(m_deferredEventsQueue.empty()) {
		std::cerr << "Failed to GetNextDeferredEvent: Queue is empty" << std::endl;
		return;
	}

	DeferredEvent event = m_deferredEventsQueue.front();

	// LuaJIT is expected to manage the lifetime of the cdata, so we don't have to
	preallocatedEventBuffer->type = static_cast<int>(event.type);

	strncpy(preallocatedEventBuffer->clientID, event.clientID.c_str(), sizeof(preallocatedEventBuffer->clientID));
	preallocatedEventBuffer->clientID[sizeof(preallocatedEventBuffer->clientID) - 1] = '\0';

	// If the preallocated buffer is too small, there's only so much we can do here
	size_t payloadLength = std::min(m_maxPayloadSize - 1, event.payload.size());
	if(payloadLength < event.payload.size()) std::cerr << "Warning: Payload buffer too small (data may be truncated)" << std::endl;

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
