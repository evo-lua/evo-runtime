local uv = require("uv")

local callbackCalledCount = 0
local startTime = uv.hrtime()
local ticker

local function wrappedCallback()
	callbackCalledCount = callbackCalledCount + 1
	if callbackCalledCount >= 3 then
		ticker:stop()
		ticker:close()
		uv.stop()
	end
end

ticker = C_Timer.NewTicker(100, wrappedCallback)

uv.run()

local elapsed = (uv.hrtime() - startTime) / 1e6
printf("Timer ticks: %d - duration: %d", callbackCalledCount, elapsed)

-- Timers are generally imprecise, so there's significant variance to work around (should find a better approach eventually...)
local MINIMUM_EPSILON_MODIFIER = 1 / 2

assertTrue(callbackCalledCount >= 3)
assertTrue(elapsed >= 300 * MINIMUM_EPSILON_MODIFIER)
