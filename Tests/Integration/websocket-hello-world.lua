-- import { WebSocketServer } from 'ws';

-- const wss = new WebSocketServer({ port: 8080 });
local creationOptions = {
	port = 9001
}
local server = C_Networking.CreateWebSocketServer(creationOptions)

function server:WEBSOCKET_CONNECTION_ESTABLISHED(client)

end

function server:WEBSOCKET_MESSAGE_RECEIVED(client, message, opCode)
	server:Send(client, "hello client")
end

function server:WEBSOCKET_CONNECTION_CLOSED(client, code, message)

end

-- TBD use scenario framework?

-- wss.on('connection', function connection(ws) {
--   ws.on('error', console.error);

--   ws.on('message', function message(data) {
--     console.log('received: %s', data);
--   });

--   ws.send('something');
-- });