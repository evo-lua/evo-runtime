#pragma once

#include "uws.hpp"

#include "stduuid_ffi.hpp"
#include "uws_ffi.hpp"

#include <iostream>
#include <queue>
#include <string>
#include <unordered_map>
#include <utility>

constexpr bool DEBUG_UWS_WEBSERVER = false; // Not the best logging solution, but it will have to do for now

template <typename... Args>
void UWS_DEBUG(Args&&... args) {
	if constexpr(DEBUG_UWS_WEBSERVER) {
		std::cout << "[WebServer] ";
		(std::cout << ... << std::forward<Args>(args)) << std::endl;
	}
}

struct DeferredEvent {
	enum Type {
		INVALID = 0,
		OPEN = 1,
		MESSAGE = 2,
		CLOSE = 3,
		LISTEN = 4,
		SHUTDOWN = 5,
	};

	Type type;
	std::string clientID;
	std::string payload;

	DeferredEvent(Type type, std::string clientID, std::string payload)
		: type(type)
		, clientID(std::move(clientID))
		, payload(std::move(payload)) { }
};

struct PerSocketData {
	std::string clientID;
};

// Template parameters: isUsingSSL, isServer, userdataStructLayout
// Note: Clients are NYI in uws (as of 16/04/2023) so all sockets are assumed to be serverside
using WebSocket = uWS::WebSocket<false, true, PerSocketData>;
using SecureWebSocket = uWS::WebSocket<true, true, PerSocketData>;

class WebServer {
public:
	// Setup and configuration
	WebServer();
	void StartListening(int port);
	void StopListening();
	size_t GetMaxAllowedPayloadSize();

	// Routing
	void AddWebSocketRoute(std::string route, uWS::App::WebSocketBehavior<PerSocketData>&& wsBehavior);

	// Event handlers (uws glue)
	void OnUpgrade(auto* response, auto* request, auto* context);
	void OnWebSocketOpen(auto* webSocket);
	void OnWebSocketClose(auto* webSocket, int code, std::string_view message);
	void OnWebSocketMessage(auto* webSocket, std::string_view message, uWS::OpCode opCode);

	// Connection management
	size_t GetNumConnectedClients();
	WebSocket* FindClientByID(const std::string& clientID);
	void DisconnectAllClients();
	size_t PurgeFadedClients();

	// Messaging
	WebSocket::SendStatus BroadcastTextMessage(const std::string& message);
	WebSocket::SendStatus BroadcastBinaryMessage(const std::string& message);
	WebSocket::SendStatus BroadcastCompressedTextMessage(const std::string& message);
	WebSocket::SendStatus SendTextMessageToClient(const std::string& message, const std::string& clientID);
	WebSocket::SendStatus SendBinaryMessageToClient(const std::string& message, const std::string& clientID);
	WebSocket::SendStatus SendCompressedTextMessageToClient(const std::string& message, const std::string& clientID);

	// Async polling (Lua/C++ interop)
	size_t GetNumDeferredEvents();
	bool HasDeferredEvents();
	void GetNextDeferredEvent(uws_webserver_event_t* preallocatedEventBuffer);

	// Debugging
	void SetEchoMode(bool enabledFlag);
	void DumpConfiguredSettings();
	void DumpDeferredEvents();

private:
	// Internal references (used to make us and uws API calls)
	uWS::TemplatedApp<false> m_uwsAppHandle; // Set isUsingSSL=true once SSL support is in
	struct us_listen_socket_t* m_usListenSocket;

	// Auxiliary state (needed because uws doesn't provide APIs for these)
	std::queue<DeferredEvent> m_deferredEventsQueue;
	std::unordered_map<std::string, WebSocket*> m_websocketClientsMap;

	// Server settings (should be configurable)
	bool m_isEchoServer = false;

	size_t m_maxPayloadSize = 16 * 1024 * 1024; // 16 MB is required for passing the Autobahn performance test cases
	size_t m_maxBackpressureLimit = 64 * 1024;
	size_t m_idleTimeoutInSeconds = 120;
	size_t m_maxSocketLifetimeInMinutes = 0;

	bool m_sendPingsAutomatically = true;
	bool m_closeOnBackpressureLimit = false;
	bool m_resetIdleTimeoutOnSend = true;

	uWS::CompressOptions m_compressionMode = uWS::SHARED_COMPRESSOR;
};
