local uv = require("uv")

local function waitFor(milliseconds)
	local done = false
	local timer = uv.new_timer()
	timer:start(milliseconds, 0, function()
		timer:stop()
		timer:close()
		done = true
	end)
	repeat
		uv.run("once")
	until done
end

-- Timers are generally imprecise, so there's significant variance to work around (should find a better approach eventually...)
local MINIMUM_EPSILON_MODIFIER = 1 / 2
local MAXIMUM_EPSILON_MODIFIER = 2

describe("C_Timer", function()
	describe("ResumeAfter", function()
		it("should throw if called outside of a coroutine", function()
			local function resumeFromMainThread()
				C_Timer.ResumeAfter(42)
			end
			assertThrows(resumeFromMainThread, "Cannot yield from the main thread (wrap async task in a coroutine)")
		end)

		it("should throw if no delay was given", function()
			local function resumeWithoutDelay()
				C_Timer.ResumeAfter(nil)
			end
			assertThrows(
				resumeWithoutDelay,
				"Expected argument delayInMilliseconds to be a number value, but received a nil value instead"
			)
		end)
	end)

	describe("After", function()
		it("should throw if no delay was given", function()
			local function resumeWithoutDelay()
				C_Timer.After(nil)
			end
			assertThrows(
				resumeWithoutDelay,
				"Expected argument delayInMilliseconds to be a number value, but received a nil value instead"
			)
		end)

		it("should throw if no callback was given", function()
			local function resumeWithoutCallback()
				C_Timer.After(42, nil)
			end
			assertThrows(
				resumeWithoutCallback,
				"Expected argument callback to be a function value, but received a nil value instead"
			)
		end)

		it("should invoke the callback after the specified delay", function()
			local callbackCalled = false
			C_Timer.After(100, function()
				callbackCalled = true
			end)
			waitFor(100 * MAXIMUM_EPSILON_MODIFIER)
			assertTrue(callbackCalled)
		end)
	end)

	describe("NewTicker", function()
		it("should throw if no delay was given", function()
			local function resumeWithoutDelay()
				C_Timer.NewTicker(nil)
			end
			assertThrows(
				resumeWithoutDelay,
				"Expected argument delayInMilliseconds to be a number value, but received a nil value instead"
			)
		end)

		it("should throw if no callback was given", function()
			local function resumeWithoutCallback()
				C_Timer.NewTicker(42, nil)
			end
			assertThrows(
				resumeWithoutCallback,
				"Expected argument callback to be a function value, but received a nil value instead"
			)
		end)
	end)

	describe("Stop", function()
		it("should throw if no timer was given", function()
			local function stopWithoutTimer()
				C_Timer.Stop(nil)
			end
			assertThrows(
				stopWithoutTimer,
				"Expected argument tickerOrOneshotTimer to be a userdata value, but received a nil value instead"
			)
		end)

		it("should stop and close a timer", function()
			local callbackCalled = false
			local timer = C_Timer.After(100, function()
				callbackCalled = true
			end)
			C_Timer.Stop(timer)
			waitFor(100 * MAXIMUM_EPSILON_MODIFIER)
			assertFalse(callbackCalled)
		end)

		it("should stop and close a ticker", function()
			local callbackCalledCount = 0
			local ticker = C_Timer.NewTicker(100, function()
				callbackCalledCount = callbackCalledCount + 1
			end)
			waitFor(2 * 100 * MAXIMUM_EPSILON_MODIFIER)
			C_Timer.Stop(ticker)
			waitFor(2 * 100 * MAXIMUM_EPSILON_MODIFIER)
			assertTrue(callbackCalledCount >= 2)
		end)
	end)

	describe("Defer", function()
		it("should throw if callback is not a function", function()
			local function deferWithInvalidCallback()
				C_Timer.Defer("not a function")
			end
			assertThrows(
				deferWithInvalidCallback,
				"Expected argument callback to be a function value, but received a string value instead"
			)
		end)

		it("should execute the callback after polling for I/O events", function()
			local callbackCalled = false

			local function callback()
				callbackCalled = true
			end

			C_Timer.Defer(callback)
			waitFor(1)

			assertTrue(callbackCalled)
		end)

		it("should execute multiple deferred callbacks in the order they were added", function()
			local executionOrder = {}

			local function callback1()
				table.insert(executionOrder, 1)
			end

			local function callback2()
				table.insert(executionOrder, 2)
			end

			local function callback3()
				table.insert(executionOrder, 3)
			end

			C_Timer.Defer(callback1)
			C_Timer.Defer(callback2)
			C_Timer.Defer(callback3)

			waitFor(1)

			assertEquals(executionOrder, { 1, 2, 3 })
		end)

		it(
			"should yield and resume the coroutine immediately after polling for I/O when no callback is provided",
			function()
				local hasResumedCoroutine = false
				local newThread = coroutine.create(function()
					C_Timer.Defer()
					hasResumedCoroutine = true
				end)

				coroutine.resume(newThread)
				waitFor(1)

				assertTrue(hasResumedCoroutine)
			end
		)
	end)

	describe("Pause", function()
		it("should throw if no timer was given", function()
			local function pauseWithoutTimer()
				C_Timer.Pause(nil)
			end
			assertThrows(
				pauseWithoutTimer,
				"Expected argument tickerOrOneshotTimer to be a userdata value, but received a nil value instead"
			)
		end)

		it("should pause a timer", function()
			local callbackCalled = false
			local timer = C_Timer.After(100, function()
				callbackCalled = true
			end)
			C_Timer.Pause(timer)
			waitFor(100 * MAXIMUM_EPSILON_MODIFIER)
			assertFalse(callbackCalled)
		end)

		it("should pause a ticker", function()
			local callbackCalledCount = 0
			local ticker = C_Timer.NewTicker(100, function()
				callbackCalledCount = callbackCalledCount + 1
			end)
			C_Timer.Pause(ticker)
			waitFor(2 * 100 * MAXIMUM_EPSILON_MODIFIER)
			assertEquals(callbackCalledCount, 0)
		end)
	end)

	describe("Resume", function()
		it("should resume a paused timer", function()
			local callbackCalled = false
			local timer = C_Timer.After(100, function()
				callbackCalled = true
			end)
			C_Timer.Pause(timer)
			waitFor(1)
			assertFalse(callbackCalled)
			C_Timer.Resume(timer)
			waitFor(100 * MAXIMUM_EPSILON_MODIFIER)
			assertTrue(callbackCalled)
		end)

		it("should resume a paused ticker", function()
			local callbackCalledCount = 0
			local ticker = C_Timer.NewTicker(100, function()
				callbackCalledCount = callbackCalledCount + 1
			end)
			waitFor(1)
			C_Timer.Pause(ticker)
			waitFor(2 * 100 * MAXIMUM_EPSILON_MODIFIER)
			assertEquals(callbackCalledCount, 0)
			C_Timer.Resume(ticker)
			waitFor(2 * 100 * MAXIMUM_EPSILON_MODIFIER)
			assertTrue(callbackCalledCount >= 1)
		end)
	end)

	describe("GetRemainingTime", function()
		it("should throw if no timer was given", function()
			local function getRemainingTimeWithoutTimer()
				C_Timer.GetRemainingTime(nil)
			end
			assertThrows(
				getRemainingTimeWithoutTimer,
				"Expected argument tickerOrOneshotTimer to be a userdata value, but received a nil value instead"
			)
		end)

		it("should return the remaining time for a timer", function()
			local timer = C_Timer.After(100, function() end)
			waitFor(50)
			local remainingTime = C_Timer.GetRemainingTime(timer)
			assertTrue(remainingTime > 0 and remainingTime <= 50)
		end)

		it("should return 0 if the timer is already closed", function()
			local timer = C_Timer.After(100, function() end)
			C_Timer.Stop(timer)
			local remainingTime = C_Timer.GetRemainingTime(timer)
			assertEquals(remainingTime, 0)
		end)
	end)

	describe("GetElapsedTime", function()
		it("should throw if no timer was given", function()
			local function getElapsedTimeWithoutTimer()
				C_Timer.GetElapsedTime(nil)
			end
			assertThrows(
				getElapsedTimeWithoutTimer,
				"Expected argument tickerOrOneshotTimer to be a userdata value, but received a nil value instead"
			)
		end)

		it("should return the elapsed time for a timer", function()
			local timer = C_Timer.After(100, function() end)
			waitFor(50)
			local elapsedTime = C_Timer.GetElapsedTime(timer)
			assertTrue(elapsedTime >= 50 * MINIMUM_EPSILON_MODIFIER and elapsedTime < 100 * MAXIMUM_EPSILON_MODIFIER)
		end)

		it("should return approximately 0 if the timer is already closed", function()
			local timer = C_Timer.After(100, function() end)
			C_Timer.Stop(timer)
			local elapsedTime = C_Timer.GetElapsedTime(timer)
			assertTrue(math.abs(elapsedTime) < 1e-2) -- Close enough (may be slightly off due to the high resolution clock)
		end)
	end)
end)
