#include <iostream>
#include <uv.h>
#include <uwebsockets/App.h>

class MyServer {
public:
    MyServer() : app(uWS::App().get()){
        app->get("/", [](uWS::HttpResponse *res, uWS::HttpRequest req, char *data, size_t length, size_t remainingBytes) {
            res->end("Hello from uWebSockets!");
        });

        app->ws<MyServer>("/*", {
            /* Settings */
            .compression = uWS::SHARED_COMPRESSOR,
            .maxPayloadLength = 16 * 1024,
            .idleTimeout = 10,
            /* Handlers */
            .open = &MyServer::onConnection,
            .message = &MyServer::onMessage,
            .drain = &MyServer::onDrain,
            .close = &MyServer::onDisconnection,
        });
    }

    void onConnection(uWS::WebSocket<uWS::SERVER> *ws, uWS::HttpRequest req) {
        std::cout << "WebSocket connection established" << std::endl;
    }

    void onMessage(uWS::WebSocket<uWS::SERVER> *ws, char *message, size_t length, uWS::OpCode opCode) {
        std::cout << "Received message: " << std::string(message, length) << std::endl;
        ws->send(message, length, opCode);
    }

    void onDrain(uWS::WebSocket<uWS::SERVER> *ws) {
        std::cout << "WebSocket send buffer drained" << std::endl;
    }

    void onDisconnection(uWS::WebSocket<uWS::SERVER> *ws, int code, char *message, size_t length) {
        std::cout << "WebSocket connection closed with code " << code << " and message: " << std::string(message, length) << std::endl;
    }

    void run(const char* hostname, int port) {
        uv_loop_t* loop = uv_default_loop();

        // Register the WebSocket server to the libuv event loop
        uv_idle_init(loop, &idler);
uv_idle_start(&idler, [](uv_idle_t* handle) {
auto server = reinterpret_cast<MyServer*>(handle->data);
server->app->poll();
});
idler.data = this;

    // Start the WebSocket server
    app->listen(hostname, port, [this](uWS::WebSocket<uWS::SERVER> *ws) {
        ws->setData(this);
    }).run();
}
