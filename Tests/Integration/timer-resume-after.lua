local uv = require("uv")

-- Timers are generally imprecise, so there's significant variance to work around (should find a better approach eventually...)
local MINIMUM_EPSILON_MODIFIER = 1 / 2
local MAXIMUM_EPSILON_MODIFIER = 2

local delay = 50
local numIterations = 100
local elapsedTimes = {}
local function scheduleNextIteration(i)
	local newThread = coroutine.create(function()
		local startTime = uv.hrtime()
		C_Timer.ResumeAfter(delay)
		local elapsedTime = (uv.hrtime() - startTime) / 1e6
		table.insert(elapsedTimes, elapsedTime)
	end)

	coroutine.resume(newThread)
	uv.run()
end

for i = 1, numIterations, 1 do
	scheduleNextIteration(i)
end
assertEquals(#elapsedTimes, numIterations)

local minTime = delay * MINIMUM_EPSILON_MODIFIER
local maxTime = delay * MAXIMUM_EPSILON_MODIFIER

local avgTime = 0
for k, elapsedTime in ipairs(elapsedTimes) do
	avgTime = avgTime + elapsedTime / numIterations
end

dump(elapsedTimes)
printf("Avg: %.2f - Min: %.2f - Max: %.2f", avgTime, minTime, maxTime)

assertTrue(avgTime >= minTime)
assertTrue(avgTime <= maxTime)
