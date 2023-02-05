// #include <iostream>
// #include <uv.h>
// #include <libwebsockets.h>
// #include <queue>
// #include <string>

// class C_WebSocket {
// public:
// 	C_WebSocket() {
// 		loop = uv_default_loop();
// 		context = nullptr;
// 	}

// 	~C_WebSocket() {
// 		if(context) {
// 			lws_context_destroy(context);
// 		}
// 	}

// 	void StartWebsocketServer(const char* hostname, int port) {
// 		// ...
// 		uv_idle_start(&idler, [](uv_idle_t* handle) {
// 			auto ws = reinterpret_cast<C_WebSocket*>(handle->data);
// 			lws_service(ws->context, 0);
// 		});
// 		idler.data = this;
// 	}

// 	void SendMessage(const char* message) {
// 		// std::unique_lock<std::mutex> lock(send_queue_mutex);
// 		send_queue.push(message);
// 		lws_callback_on_writable_all_protocol(context, websocket_protocol);
// 	}

// 	int GetNumMessages() {
// 		// std::unique_lock<std::mutex> lock(recv_queue_mutex);
// 		return recv_queue.size();
// 	}

// 	const char* GetMessage() {
// 		// std::unique_lock<std::mutex> lock(recv_queue_mutex);
// 		if(recv_queue.empty()) {
// 			return nullptr;
// 		}
// 		auto message = recv_queue.front();
// 		recv_queue.pop();
// 		return message.c_str();
// 	}

// private:
// 	uv_loop_t* loop;
// 	lws_context* context;
// 	uv_idle_t idler;

// 	std::queue<std::string> recv_queue;
// 	std::queue<std::string> send_queue;
// 	// std::mutex recv_queue_mutex;
// 	// std::mutex send_queue_mutex;

// 	static int callback_http(lws* wsi, lws_callback_reasons reason, void* user, void* in, size_t len) {
// 		return 0;
// 	}

// 	static int callback_websocket(lws* wsi, lws_callback_reasons reason, void* user, void* in, size_t len) {
// 		auto ws = reinterpret_cast<C_WebSocket*>(lws_context_user(lws_get_context(wsi)));
// 		switch(reason) {
// 		case LWS_CALLBACK_ESTABLISHED:
// 			std::cout << "WebSocket connection established" << std::endl;
// 			break;
// 		case LWS_CALLBACK_RECEIVE:
// 			// std::unique_lock<std::mutex> lock(ws->recv_queue_mutex);
// 			ws->recv_queue.push(std::string(reinterpret_cast<char*>(in), len));
// 			break;
// 		case LWS_CALLBACK_SERVER_WRITEABLE:
// 			// std::unique_lock<std::mutex> lock(ws->send_queue_mutex);
// 			if(ws->send_queue.empty()) {
// 				break;
// 			default:
// 				// Ignored, for now
// 				std::cout << "Ignored callback with reason " << reason << std::endl;
// 				break;
// 			}
// 			auto message = ws->send_queue.front();
// 			ws->send_queue.pop();
// 			auto buf = lws_write(wsi, reinterpret_cast<unsigned char*>(&message[0]), message.size(), LWS_WRITE_BINARY);
// 			std::cout << "Echoing message: " << buf << std::endl;
// 			break;
// 		}
// 	}

// 	// static lws_protocols protocols[] = {
// 	// 	{ "http", callback_http, 0, 0 },
// 	// 	{ "websocket", callback_websocket, 0, 0 },
// 	// 	{ nullptr, nullptr, 0, 0 }
// 	// };
// };

/*
 * lws-minimal-secure-streams-server
 *
 * Written in 2010-2021 by Andy Green <andy@warmcat.com>
 *
 * This file is made available under the Creative Commons CC0 1.0
 * Universal Public Domain Dedication.
 *
 * Simplest possible SS https server
 */

#include <libwebsockets.h>
#include <signal.h>

extern const lws_ss_info_t ssi_myss_srv_t;

static struct lws_context* cx;
int test_result = 0, multipart;

// static int
// smd_cb(void* opaque, lws_smd_class_t c, lws_usec_t ts, void* buf, size_t len) {
// 	if(!(c & LWSSMDCL_SYSTEM_STATE) || lws_json_simple_strcmp(buf, len, "\"state\":", "OPERATIONAL") || !lws_ss_create(cx, 0, &ssi_myss_srv_t, NULL, NULL, NULL, NULL))
// 		return 0;

// 	lwsl_err("%s: failed to create secure stream\n", __func__);
// 	lws_default_loop_exit(cx);

// 	return -1;
// }

// TBD not needed if handled from inside the runtime
static void
sigint_handler(int sig) {
	lws_default_loop_exit(cx);
}

int lws_test(int argc, const char** argv) { // TODO should be const char in main also
	struct lws_context_creation_info info;

	lws_context_info_defaults(&info, "example-policy.json");
	lws_cmdline_option_handle_builtin(argc, argv, &info);
	signal(SIGINT, sigint_handler);

	lwsl_user("LWS Secure Streams Server\n");

	// info.early_smd_cb = smd_cb;
	// info.early_smd_class_filter = LWSSMDCL_SYSTEM_STATE;

	cx = lws_create_context(&info);
	if(!cx) {
		lwsl_err("lws init failed\n");
		return 1;
	}

	lws_context_default_loop_run_destroy(cx);

	/* process ret 0 if actual is as expected (0, or--expected-exit 123) */

	return lws_cmdline_passfail(argc, argv, test_result);
}
