local etrace = require("etrace")
local uv = require("uv")

local AsyncFileReader = require("Runtime.API.FileSystem.AsyncFileReader") -- C_FileSystem.AsyncFileReader

local function assertEventTrigger(functionToObserve, expectedEvent, expectedPayload, numExpectedNotifications)
	numExpectedNotifications = numExpectedNotifications or 1

	etrace.clear()
	local wasEventEnabled = etrace.status(expectedEvent)

	etrace.enable(expectedEvent)
	functionToObserve()
	uv.run()

	local observedEvents = etrace.filter(expectedEvent)
	assertEquals(#observedEvents, numExpectedNotifications)

	for index = 1, numExpectedNotifications, 1 do
		local event = observedEvents[index]
		assertEquals(event.name, expectedEvent)
		assertEquals(event.payload, expectedPayload)
	end

	if wasEventEnabled then
		etrace.enable(expectedEvent)
	end

	uv.stop()
end

describe("AsyncFileReader", function()
	describe("LoadFileContents", function()
		it("should trigger FILE_REQUEST_FAILED if the given path is invalid", function()
			assertEventTrigger(
				function()
					AsyncFileReader:LoadFileContents("does-not-exist")
				end,
				"FILE_REQUEST_FAILED",
				{
					fileSystemPath = "does-not-exist",
					message = "ENOENT: no such file or directory: does-not-exist",
				}
			)
		end)

		it("should trigger FILE_REQUEST_FAILED if the given path refers to a directory", function()
			assertEventTrigger(
				function()
					AsyncFileReader:LoadFileContents("Runtime")
				end,
				"FILE_REQUEST_FAILED",
				{
					fileSystemPath = "Runtime",
					message = "EISDIR: illegal operation on a directory",
				}
			)
		end)
	end)
end)
