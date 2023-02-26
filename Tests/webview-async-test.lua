local webview = require("webview")
local webview_create = webview.bindings.webview_create
local webview_navigate = webview.bindings.webview_navigate
local webview_run = webview.bindings.webview_run
local webview_run_once = webview.bindings.webview_run_once
local webview_terminate = webview.bindings.webview_terminate

-- TODO C_WebView.Create
-- NavigateToURL
-- RunForever
-- RunOnce(inBlockingMode) -- OSX blocking, TBD?
-- Shutdown/Close

local view = webview_create(true, nil)

-- TODO start timer to kill idle (and webview)

-- TODO start webview with run, it should block the idle
-- TODO start webview with run_once, blocking. should block the idle
-- TODO start webview with run_once, nonblocking. should NOT block the idle
-- TODO stop uv run if idle has counted enough / or use timer
local uv = require("uv")
local numEventLoopIerations = 0
local idle = uv.new_idle()
idle:start(function()
	numEventLoopIerations = numEventLoopIerations + 1
	print("Before I/O polling, no blocking", numEventLoopIerations)

	-- BLOCKS the event loop (don't do this if you need other work to complete!)
	webview_run(view)

	if numEventLoopIerations == 100 then
		print("Stopping event loop", numEventLoopIerations)
		-- uv.stop()
	end
end)
uv.run()
