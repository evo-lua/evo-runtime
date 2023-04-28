local testFiles = {
	"Tests/Integration/uws-echo-server.lua",
	"Tests/Integration/uws-event-queue.lua",
	"Tests/Integration/websocket-echo-server.lua",
	"Tests/Integration/websocket-event-queue.lua",
	"Tests/Integration/websocket-messaging.lua",
	"Tests/Integration/http-routing.lua",
	"Tests/Integration/http-event-queue.lua",
	"Tests/Integration/http-shutdown-with-503.lua",
}

local numFailedTests = C_Runtime.RunBasicTests(testFiles)
os.exit(numFailedTests)
