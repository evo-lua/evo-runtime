#include <iostream>
#include <uv.h>
#include <libwebsockets.h>
#include <queue>
#include <string>

class C_WebSocket {
public:
	C_WebSocket() {
		loop = uv_default_loop();
		context = nullptr;
	}

	~C_WebSocket() {
		if(context) {
			lws_context_destroy(context);
		}
	}

	void StartWebsocketServer(const char* hostname, int port) {
		// ...
		uv_idle_start(&idler, [](uv_idle_t* handle) {
			auto ws = reinterpret_cast<C_WebSocket*>(handle->data);
			lws_service(ws->context, 0);
		});
		idler.data = this;
	}

	void SendMessage(const char* message) {
		// std::unique_lock<std::mutex> lock(send_queue_mutex);
		send_queue.push(message);
		lws_callback_on_writable_all_protocol(context);
	}

	int GetNumMessages() {
		// std::unique_lock<std::mutex> lock(recv_queue_mutex);
		return recv_queue.size();
	}

	const char* GetMessage() {
		// std::unique_lock<std::mutex> lock(recv_queue_mutex);
		if(recv_queue.empty()) {
			return nullptr;
		}
		auto message = recv_queue.front();
		recv_queue.pop();
		return message.c_str();
	}

private:
	uv_loop_t* loop;
	lws_context* context;
	uv_idle_t idler;

	std::queue<std::string> recv_queue;
	std::queue<std::string> send_queue;
	// std::mutex recv_queue_mutex;
	// std::mutex send_queue_mutex;

	static int callback_http(lws* wsi, lws_callback_reasons reason, void* user, void* in, size_t len) {
		return 0;
	}

	static int callback_websocket(lws* wsi, lws_callback_reasons reason, void* user, void* in, size_t len) {
		auto ws = reinterpret_cast<C_WebSocket*>(lws_context_user(lws_get_context(wsi)));
		switch(reason) {
		case LWS_CALLBACK_ESTABLISHED:
			std::cout << "WebSocket connection established" << std::endl;
			break;
		case LWS_CALLBACK_RECEIVE:
			// std::unique_lock<std::mutex> lock(ws->recv_queue_mutex);
			ws->recv_queue.push(std::string(reinterpret_cast<char*>(in), len));
			break;
		case LWS_CALLBACK_SERVER_WRITEABLE:
			// std::unique_lock<std::mutex> lock(ws->send_queue_mutex);
			if(ws->send_queue.empty()) {
				break;
			default:
				// Ignored, for now
				std::cout << "Ignored callback with reason " << reason << std::endl;
				break;
			}
			auto message = ws->send_queue.front();
			ws->send_queue.pop();
			auto buf = lws_write(wsi, reinterpret_cast<unsigned char*>(&message[0]), message.size(), LWS_WRITE_BINARY);
			break;
		}
	}

	static lws_protocols protocols[] = {
		{ "http", callback_http, 0, 0 },
		{ "websocket", callback_websocket, 0, 0 },
		{ nullptr, nullptr, 0, 0 }
	};
};