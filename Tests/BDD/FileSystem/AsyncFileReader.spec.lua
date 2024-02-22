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

local OLD_CHUNK_SIZE = AsyncFileReader.CHUNK_SIZE_IN_BYTES
local NEW_CHUNKS_SIZE = 2 -- No point in generating large payloads here
local MAX_LENGTH_CHUNK = string.rep("A", NEW_CHUNKS_SIZE)
AsyncFileReader.CHUNK_SIZE_IN_BYTES = NEW_CHUNKS_SIZE

local SMALL_TEST_FILE = "temp-small.txt"
local LARGE_TEST_FILE = "temp-large.txt"
local FILE_CONTENTS_SMALL = string.rep("A", NEW_CHUNKS_SIZE - 1)
local FILE_CONTENTS_LARGE = MAX_LENGTH_CHUNK .. MAX_LENGTH_CHUNK
C_FileSystem.WriteFile(SMALL_TEST_FILE, FILE_CONTENTS_SMALL)
C_FileSystem.WriteFile(LARGE_TEST_FILE, FILE_CONTENTS_LARGE)

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


		it("should trigger FILE_CHUNK_AVAILABLE if the read requires buffering", function()
			local numExpectedChunks = 2
			local function loadSmallFile()
				AsyncFileReader:LoadFileContents(LARGE_TEST_FILE)
			end
			local expectedPayload = {
				fileSystemPath = LARGE_TEST_FILE, -- CHUNK_BYTES
				chunk = MAX_LENGTH_CHUNK,
			}
			-- loadSmallFile()
			-- uv.run()
			-- local events = etrace.filter("FILE_CHUNK_AVAILABLE")
			-- error(dump(events))
			assertEvent(loadSmallFile, "FILE_CHUNK_AVAILABLE", expectedPayload, numExpectedChunks)
		end)
	end)
end)

C_FileSystem.Delete(SMALL_TEST_FILE)
C_FileSystem.Delete(LARGE_TEST_FILE)
AsyncFileReader.CHUNK_SIZE_IN_BYTES = OLD_CHUNK_SIZE