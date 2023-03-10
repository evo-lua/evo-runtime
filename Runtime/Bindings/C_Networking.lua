local WebSocketServer = {}

-- should validate options, error on schema validation, cert/key 404, port unavailable
-- should register uv update (updateFrequency = fps/target tick rate)
-- should be able to receive messages (async)
-- should be able to send msg
-- backpressure, buffered amount check, drain/ dropped msgs
-- string vs binary, also utf8?
-- autobahn echo test (C_TestRunner.CreateWebSocketEchoServer)
function WebSocketServer:Construct(serverCreationOptions)

end

-- metatable, call, index, blabla

------------------

-- TBD move to C++, use actual structs, return userdata (vs cdata? FFI might be faster but we won't allocate many instances...)
local C_Networking = {}

-- TCP / UDP / DHCP / DNS / ... ?
-- SecureTCP ?

function C_Networking.CreateWebServer(serverCreationOptions) end -- HTTP
function C_Networking.CreateSecureWebServer(serverCreationOptions) end -- HTTPS

function C_Networking.CreateWebSocketServer(serverCreationOptions) end
function C_Networking.CreateSecureWebSocketServer(serverCreationOptions) end

return C_Networking
