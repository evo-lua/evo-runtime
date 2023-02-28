-- TODO use timer_cb instead of idler pattern, too much CPU usage

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

-- webview::webview w(true, nullptr);
-- // webview::webview w2(true, nullptr);
-- w.set_title("First window");
-- w.set_size(640, 480, WEBVIEW_HINT_NONE);
-- w.navigate("https://en.m.wikipedia.org/wiki/Main_Page");

local WEBVIEW_HINT_NONE = 0
webview.bindings.webview_set_size(view, 640, 480, WEBVIEW_HINT_NONE);
webview.bindings.webview_set_title(view, "First window")
webview.bindings.webview_navigate(view, "https://en.m.wikipedia.org/wiki/Main_Page");
--
-- webview.bindings.webview_run(wv)

-- TODO start timer to kill idle (and webview)

-- TODO start webview with run, it should block the idle
-- TODO start webview with run_once, blocking. should block the idle
-- TODO start webview with run_once, nonblocking. should NOT block the idle
-- TODO stop uv run if idle has counted enough / or use timer
local uv = require("uv")
local numEventLoopIerations = 0

-- Creating a simple setInterval wrapper
local function setInterval(interval, callback)
	local timer = uv.new_timer()
	timer:start(interval, interval, function ()
	  callback()
	end)
	return timer
  end

local simulateBlockingWorkTimer = uv.new_timer()
simulateBlockingWorkTimer:start(5000, 5000, function()
	-- print("Simulating heavy CPU load now, for 2.5 seconds (UI should become unresponsive)")
	-- uv.sleep(2500) -- Simulate decoding for 2.5sec or whatever (not a good idea to do this on the main thread)
end)

local TARGET_FPS = 60 -- Since timers are inherently at least a little inaccurate, might have to be increased ?
local GUI_UPDATE_INTERVAL_IN_MS = 1000 / TARGET_FPS
local guiUpdateTimer = uv.new_timer()
-- local idle = uv.new_idle()
-- idle:start(function()
	-- timerAsUserdata, timeout, repeatAfter, callback
	guiUpdateTimer:start(GUI_UPDATE_INTERVAL_IN_MS, GUI_UPDATE_INTERVAL_IN_MS,function()
	numEventLoopIerations = numEventLoopIerations + 1
	-- TBD rename to numUpdates since it doesn't correspond 1:1 to the event ticks anymore
	-- print("GUI_UPDATE No. " ..  numEventLoopIerations .. " (performed at " .. TARGET_FPS .. " FPS - one update every " .. GUI_UPDATE_INTERVAL_IN_MS .. " ms)")
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
