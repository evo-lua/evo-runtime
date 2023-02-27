local webview = require("webview")
local webview_create = webview.bindings.webview_create
local webview_navigate = webview.bindings.webview_navigate
local webview_run = webview.bindings.webview_run
local webview_run_once = webview.bindings.webview_run_once
local webview_terminate = webview.bindings.webview_terminate
local webview_destroy = webview.bindings.webview_destroy

-- TODO C_WebView.Create
-- NavigateToURL
-- RunForever
-- RunOnce(inBlockingMode) -- OSX blocking, TBD?
-- Shutdown/Close

-- Docs:
-- Scenario one: 1 webview, run blocking -> observation: async work pauses until window is close,d then resumes)
-- 2: 1 webview, run_once blocking (standalone, not inside idle)-> wv updates once then freezes (blocking has no effect?)
-- same, but inside idle -> wv updates and so does event loop (console output is choppy, but let's ignore that for now)
-- set blocking to false, updates much faster?? WTF does it do?

-- TODO convert to actual test case, with timer or just idle count
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
	-- webview_run_once(view, true)
	webview_run_once(view, false)

	-- webview_run_once(view, true)
	if numEventLoopIerations == 25 then
		print("Stopping event loop", numEventLoopIerations)
		-- TODO disable these three for the tutorial, but enable for unit test
		--uv.stop()
		-- webview_terminate(view)
		--webview_destroy(view)
	end
end)

-- BLOCKS the event loop (don't do this if you need other work to complete!)
-- webview_run(view)
-- webview_terminate(view)
-- webview_destroy(view)

uv.run()
