local testFiles = {
	"Tests/Integration/uws-echo-server.lua",
	"Tests/Integration/uws-event-queue.lua",
	"Tests/Integration/websocket-echo-server.lua",
	"Tests/Integration/websocket-event-queue.lua",
	"Tests/Integration/websocket-messaging.lua",
}

local numFailedTests = C_Runtime.RunBasicTests(testFiles)
os.exit(numFailedTests)
