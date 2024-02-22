local etrace = require("etrace")
local uv = require("uv")

local AsyncFileReader = require("Runtime.API.FileSystem.AsyncFileReader") -- C_FileSystem.AsyncFileReader

local function assertEvent(functionToObserve, expectedEvent, expectedPayload, numExpectedNotifications)
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
		for key, value in pairs(expectedPayload) do
			assertEquals(event.payload[key], value)
		end
	end

	if wasEventEnabled then
		etrace.enable(expectedEvent)
	end
end

local SMALL_TEST_FILE = "temp-small.txt"
local FILE_CONTENTS_SMALL = string.rep("A", 1)--AsyncFileReader.CHUNK_SIZE_IN_BYTES - 1)
C_FileSystem.WriteFile(SMALL_TEST_FILE, FILE_CONTENTS_SMALL)

describe("AsyncFileReader", function()
	describe("LoadFileContents", function()
		it("should trigger FILE_REQUEST_FAILED if the given path is invalid", function()
			local function loadInvalidPath()
				AsyncFileReader:LoadFileContents("does-not-exist")
			end
			local expectedPayload = {
				fileSystemPath = "does-not-exist",
				message = "ENOENT: no such file or directory: does-not-exist",
			}
			assertEvent(loadInvalidPath, "FILE_REQUEST_FAILED", expectedPayload)
		end)

		it("should trigger FILE_REQUEST_FAILED if the given path refers to a directory", function()
			local function loadDirectory()
				AsyncFileReader:LoadFileContents("Runtime")
			end
			local expectedPayload = {
				fileSystemPath = "Runtime",
				message = "EISDIR: illegal operation on a directory",
			}
			assertEvent(loadDirectory, "FILE_REQUEST_FAILED", expectedPayload)
		end)

		it("should trigger FILE_CONTENTS_AVAILABLE if the read doesn't require buffering", function()
			local function loadSmallFile()
				AsyncFileReader:LoadFileContents(SMALL_TEST_FILE)
			end
			local expectedPayload = {
				fileSystemPath = SMALL_TEST_FILE,
				fileContents = FILE_CONTENTS_SMALL,
			}
			assertEvent(loadSmallFile, "FILE_CONTENTS_AVAILABLE", expectedPayload)
		end)
	end)
end)

C_FileSystem.Delete(SMALL_TEST_FILE)