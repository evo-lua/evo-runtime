local uv = require("uv")
local validation = require("validation")

local coroutine_resume = coroutine.resume
local coroutine_running = coroutine.running
local coroutine_yield = coroutine.yield
local uv_hrtime = uv.hrtime
local uv_new_timer = uv.new_timer
local validateFunction = validation.validateFunction
local validateNumber = validation.validateNumber
local validateUserdata = validation.validateUserdata

local C_Timer = {}

local deferredCallbackChecker = uv.new_check()
local deferredCallbacks = {}
local timerCallbacks = {}
local timerStartTimes = {}

function C_Timer.ResumeAfter(delayInMilliseconds)
	validateNumber(delayInMilliseconds, "delayInMilliseconds")

	local currentThread, isMainThread = coroutine.running()
	if isMainThread then
		error("Cannot yield from the main thread (wrap async task in a coroutine)", 0)
	end

	local timer = uv_new_timer()

	timer:start(delayInMilliseconds, 0, function()
		timer:stop()
		timer:close()

		local ok, errorMessage = coroutine_resume(currentThread)
		if not ok then
			error("Error resuming coroutine: " .. errorMessage, 0)
		end
	end)

	coroutine_yield()
end

function C_Timer.After(delayInMilliseconds, callback)
	validateNumber(delayInMilliseconds, "delayInMilliseconds")
	validateFunction(callback, "callback")

	local timer = uv_new_timer()

	timer:start(delayInMilliseconds, 0, function()
		callback()

		timer:stop()
		timer:close()

		timerStartTimes[timer] = nil
		timerCallbacks[timer] = nil
	end)

	timerStartTimes[timer] = uv_hrtime()
	timerCallbacks[timer] = callback

	return timer
end

function C_Timer.NewTicker(delayInMilliseconds, callback)
	validateNumber(delayInMilliseconds, "delayInMilliseconds")
	validateFunction(callback, "callback")

	local timer = uv_new_timer()

	local function onTick()
		callback()
	end

	timer:start(delayInMilliseconds, delayInMilliseconds, onTick)

	timerStartTimes[timer] = uv_hrtime()
	timerCallbacks[timer] = onTick

	return timer
end

function C_Timer.Stop(tickerOrOneshotTimer)
	validateUserdata(tickerOrOneshotTimer, "tickerOrOneshotTimer")

	if tickerOrOneshotTimer:is_closing() then
		return
	end

	tickerOrOneshotTimer:stop()
	tickerOrOneshotTimer:close()

	timerStartTimes[tickerOrOneshotTimer] = nil
	timerCallbacks[tickerOrOneshotTimer] = nil
end

local function onCheck()
	local processedCallbacks = deferredCallbacks
	deferredCallbacks = {}
	for i = 1, #processedCallbacks do
		processedCallbacks[i]()
	end

	local hasProcessedDeferredCallbacks = (#deferredCallbacks == 0)
	if hasProcessedDeferredCallbacks then
		deferredCallbackChecker:stop()
	end
end

function C_Timer.Defer(callback)
	if callback then
		validateFunction(callback, "callback")

		local hasProcessedDeferredCallbacks = (#deferredCallbacks == 0)
		if hasProcessedDeferredCallbacks then
			deferredCallbackChecker:start(onCheck)
		end

		deferredCallbacks[#deferredCallbacks + 1] = callback
	else
		local currentThread, isMainThread = coroutine_running()
		if isMainThread then
			error("Cannot yield from the main thread (wrap async task in a coroutine)", 0)
		end

		local hasProcessedDeferredCallbacks = (#deferredCallbacks == 0)
		if hasProcessedDeferredCallbacks then
			deferredCallbackChecker:start(onCheck)
		end

		deferredCallbacks[#deferredCallbacks + 1] = function()
			coroutine_resume(currentThread)
		end
	end
end

function C_Timer.Pause(tickerOrOneshotTimer)
	validateUserdata(tickerOrOneshotTimer, "tickerOrOneshotTimer")

	if tickerOrOneshotTimer:is_closing() or not tickerOrOneshotTimer:is_active() then
		return
	end

	tickerOrOneshotTimer:stop()
end

function C_Timer.Resume(tickerOrOneshotTimer)
	validateUserdata(tickerOrOneshotTimer, "tickerOrOneshotTimer")

	if tickerOrOneshotTimer:is_closing() then
		return
	end

	local delayInMilliseconds = tickerOrOneshotTimer:get_repeat()
	local completionCallback = timerCallbacks[tickerOrOneshotTimer]

	tickerOrOneshotTimer:start(delayInMilliseconds, delayInMilliseconds, completionCallback)
end

function C_Timer.GetRemainingTime(tickerOrOneshotTimer)
	validateUserdata(tickerOrOneshotTimer, "tickerOrOneshotTimer")

	if tickerOrOneshotTimer:is_closing() then
		return 0
	end

	local dueTimeInMilliseconds = tickerOrOneshotTimer:get_due_in()
	return dueTimeInMilliseconds
end

function C_Timer.GetElapsedTime(tickerOrOneshotTimer)
	validateUserdata(tickerOrOneshotTimer, "tickerOrOneshotTimer")

	local startTime = timerStartTimes[tickerOrOneshotTimer]
	if not startTime then
		return 0
	end

	local elapsedTimeInNanoseconds = (uv_hrtime() - startTime)
	local elapsedTimeInMilliseconds = elapsedTimeInNanoseconds / 1e6

	return elapsedTimeInMilliseconds
end

return C_Timer
