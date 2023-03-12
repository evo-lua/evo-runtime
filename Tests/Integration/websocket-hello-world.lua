-- import { WebSocketServer } from 'ws';

-- const wss = new WebSocketServer({ port: 8080 });
local creationOptions = {
	port = 9001
}
-- local server = C_Networking.CreateWebSocketServer(creationOptions)
local targetTickTime = 1000 / 50 -- 60 FPS

local uv = require("uv")
local pollingUpdateTimer = uv.new_timer()
local timeBefore = uv.hrtime()
pollingUpdateTimer:start(0, 1, function()
	local timeNow = uv.hrtime()
	local timeSInceLastUpdate = timeNow - timeBefore -- ns
	local timeMS = timeSInceLastUpdate / 10E5

	timeBefore = timeNow
	local remainingTickTime = math.max(targetTickTime - timeMS, 0)
	-- print("NYI: Polling for WebSocket updates", timeMS, remainingTickTime)
	printf("Last update took %.2f ms\t\tNext update in %.2f ms", timeMS, remainingTickTime)
	uv.sleep(remainingTickTime)
end)

-- uv.run() -- TBD move to main.cpp

-- function server:WEBSOCKET_CONNECTION_ESTABLISHED(client)

-- end

-- function server:WEBSOCKET_MESSAGE_RECEIVED(client, message, opCode)
-- 	server:SendTextMessage(client, "I have received your message, and I found it wanting")
-- end

-- function server:WEBSOCKET_CONNECTION_CLOSED(client, code, message)

-- end

-- TBD use scenario framework?

-- wss.on('connection', function connection(ws) {
--   ws.on('error', console.error);

--   ws.on('message', function message(data) {
--     console.log('received: %s', data);
--   });

--   ws.send('something');
-- });