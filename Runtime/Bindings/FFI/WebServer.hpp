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
		HTTP_START = 6,
		HTTP_DATA = 7,
		HTTP_END = 8,
		HTTP_ABORT = 9,
		HTTP_WRITABLE = 10,
	};

	Type type;
	std::string clientID;
	std::string payload;

	DeferredEvent(Type type, std::string clientID, std::string payload)
		: type(type)
		, clientID(std::move(clientID))
		, payload(std::move(payload)) {}
};

// Template parameters: isUsingSSL
using HttpResponse = uWS::HttpResponse<false>;

struct HttpRequestDetails {
	std::string method;
	std::string url;
	std::string query;
	std::string endpoint;
	std::unordered_map<std::string, std::string> headers;
};

struct HttpMessageData { // TBD actually useless?
	HttpRequestDetails requestDetails;
	std::shared_ptr<HttpResponse> response;
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
	void AddWebSocketRoute(std::string route);
	void AddGetRoute(std::string route);
	void AddPostRoute(std::string route);
	void AddOptionsRoute(std::string route);
	void AddDeleteRoute(std::string route);
	void AddPatchRoute(std::string route);
	void AddPutRoute(std::string route);
	void AddHeadRoute(std::string route);
	void AddAnyRoute(std::string route);

	// Event handlers (uws glue)
	void OnUpgrade(auto* response, auto* request, auto* context);
	void OnWebSocketOpen(auto* webSocket);
	void OnWebSocketClose(auto* webSocket, int code, std::string_view message);
	void OnWebSocketMessage(auto* webSocket, std::string_view message, uWS::OpCode opCode);
	void OnRequest(std::string requestID, auto* response, auto* request, std::string route);
	void OnChunkReceived(std::string requestID, std::string_view chunk);
	void OnLastChunkReceived(std::string requestID, std::string_view chunk);
	void OnConnectionWritable(std::string requestID, long unsigned int offset);
	void OnConnectionAborted(std::string requestID);

	// Connection management
	size_t GetNumConnectedClients();
	WebSocket* FindClientByID(const std::string& clientID);
	void DisconnectAllClients();
	size_t PurgeFadedClients();
	size_t AbortAllConnections();

	// Messaging
	WebSocket::SendStatus BroadcastTextMessage(const std::string& message);
	WebSocket::SendStatus BroadcastBinaryMessage(const std::string& message);
	WebSocket::SendStatus BroadcastCompressedTextMessage(const std::string& message);
	WebSocket::SendStatus SendTextMessageToClient(const std::string& message, const std::string& clientID);
	WebSocket::SendStatus SendBinaryMessageToClient(const std::string& message, const std::string& clientID);
	WebSocket::SendStatus SendCompressedTextMessageToClient(const std::string& message, const std::string& clientID);
	HttpSendStatus WriteResponse(const std::string& requestID, const std::string& data);
	HttpSendStatus EndResponse(const std::string& requestID, const std::string& data);
	HttpSendStatus TryEndResponse(const std::string& requestID, const std::string& data);
	bool WriteResponseStatus(const std::string& requestID, const std::string& statusCodeAndText);
	bool WriteResponseHeader(const std::string& requestID, const std::string& headerName, const std::string& headerValue);

	// Async polling (Lua/C++ interop)
	size_t GetNumDeferredEvents();
	bool HasDeferredEvents();
	void GetNextDeferredEvent(uws_webserver_event_t* preallocatedEventBuffer);

	// Request details
	bool HasRequest(std::string requestID);
	bool GetRequestMethod(const std::string& requestID, char* buffer, size_t bufferSize);
	bool GetRequestURL(const std::string& requestID, char* buffer, size_t bufferSize);
	bool GetRequestQuery(const std::string& requestID, char* buffer, size_t bufferSize);
	bool GetRequestEndpoint(const std::string& requestID, char* buffer, size_t bufferSize);
	bool GetSerializedRequestHeaders(const std::string& requestID, char* buffer, size_t bufferSize);
	bool GetRequestHeader(const std::string& requestID, const std::string& headerName, char* buffer, size_t bufferSize);

	// Debugging
	void SetEchoMode(bool enabledFlag);
	void DumpConfiguredSettings();
	void DumpDeferredEvents();

private:
	// Internal helpers
	std::string GetCurrentTimeAsText();
	void CreateRouteHandler(std::string method, std::string route, auto* response, auto* request);
	bool StoreRequestDetails(std::string requestID, auto* response, auto* request, std::string route);
	void SetCallbackHandlers(std::string requestID, auto* response, auto* request);

	// Internal references (used to make us and uws API calls)
	uWS::TemplatedApp<false> m_uwsAppHandle; // Set isUsingSSL=true once SSL support is in
	struct us_listen_socket_t* m_usListenSocket = nullptr;

	// Auxiliary state (needed because uws doesn't provide APIs for these)
	std::queue<DeferredEvent> m_deferredEventsQueue;
	std::unordered_map<std::string, WebSocket*> m_websocketClientsMap;
	std::unordered_map<std::string, HttpMessageData> m_httpClientsMap;

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
