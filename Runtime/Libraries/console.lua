local buffer = require("string.buffer")
local validation = require("validation")
local validateString = validation.validateString

local ffi = require("ffi")
local uv = require("uv")

local console = {
	buffer = buffer.new(),
	backup = {},
	timers = {},
}

function console.capture()
	local hasCapturedBefore = (console.backup.print ~= nil)
	if hasCapturedBefore then
		console.buffer:reset()
		return
	end

	console.backup.print = _G.print
	_G.print = console.print
end

function console.print(...)
	local args = { ... }
	for k, v in ipairs(args) do
		console.buffer:put(v .. "\n")
	end
end

function console.release()
	local hasCapturedBefore = (console.backup.print ~= nil)
	if not hasCapturedBefore then
		return
	end

	_G.print = console.backup.print
	console.backup = {}

	local capturedOutput = tostring(console.buffer)
	console.buffer:reset()
	return capturedOutput
end

function console.startTimer(label)
	validateString(label, "label")

	local timerExists = (console.timers[label] ~= nil)
	if timerExists then
		error(format("A console timer with label '%s' already exists", label), 0)
	end

	console.timers[label] = uv.hrtime()
end

function console.stopTimer(label)
	validateString(label, "label")

	local startTimeInNanoseconds = console.timers[label]
	local timerExists = (startTimeInNanoseconds ~= nil)
	if not timerExists then
		error(format("No console timer with label '%s' currently exists", label), 0)
	end

	console.timers[label] = nil

	local endTimeInNanoseconds = uv.hrtime()
	local elapsedTimeInNanoseconds = endTimeInNanoseconds - startTimeInNanoseconds
	local elapsedTimeInMilliseconds = elapsedTimeInNanoseconds * 1E-6

	printf("%s: %.0f ms", label, elapsedTimeInMilliseconds)

	return elapsedTimeInMilliseconds
end

function console.clear()
	local isWindows = ffi.os == "Windows"

	-- A bit hacky, but it will get the job done...
	if isWindows then
		os.execute("cls")
	else
		io.write("\027[H\027[2J")
		io.flush()
	end
end

function console.printf(...)
	return print(format(...))
end

return console
