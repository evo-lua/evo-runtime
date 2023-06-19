local testFiles = {
	"Tests/Integration/uws-echo-server.lua",
	"Tests/Integration/uws-event-queue.lua",
	"Tests/Integration/websocket-echo-server.lua",
	"Tests/Integration/websocket-event-queue.lua",
	"Tests/Integration/websocket-messaging.lua",
	"Tests/Integration/glfw-window-events.lua",
	"Tests/Integration/http-routing.lua",
	"Tests/Integration/http-event-queue.lua",
	"Tests/Integration/http-shutdown-with-503.lua",
	"Tests/Integration/http-response-status.lua",
	"Tests/Integration/http-json-response.lua",
	"Tests/Integration/timer-resume-after.lua",
	"Tests/Integration/timer-ticker-callbacks.lua",
	"Tests/Integration/webview-fullscreen-mode.lua",
	"Tests/Integration/webview-app-icon.lua",
	"Tests/Integration/webview-multiple-windows.lua",
}

local numFailedTests = C_Runtime.RunBasicTests(testFiles)
os.exit(numFailedTests)
