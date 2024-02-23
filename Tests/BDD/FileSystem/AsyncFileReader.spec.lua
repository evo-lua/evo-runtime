local etrace = require("etrace")
local uv = require("uv")

local AsyncFileReader = require("AsyncFileReader")

local OLD_CHUNK_SIZE = AsyncFileReader.CHUNK_SIZE_IN_BYTES
local NEW_CHUNKS_SIZE = 2 -- No point in generating large payloads here
local MAX_LENGTH_CHUNK = string.rep("A", NEW_CHUNKS_SIZE)
AsyncFileReader.CHUNK_SIZE_IN_BYTES = NEW_CHUNKS_SIZE

local SMALL_TEST_FILE = "temp-small.txt"
local LARGE_TEST_FILE = "temp-large.txt"
local FILE_CONTENTS_SMALL = string.rep("A", NEW_CHUNKS_SIZE - 1)
local FILE_CONTENTS_LARGE = MAX_LENGTH_CHUNK .. MAX_LENGTH_CHUNK .. "A"
C_FileSystem.WriteFile(SMALL_TEST_FILE, FILE_CONTENTS_SMALL)
C_FileSystem.WriteFile(LARGE_TEST_FILE, FILE_CONTENTS_LARGE)

describe("AsyncFileReader", function()
	describe("LoadFileContents", function()
		before(function()
			etrace.enable(AsyncFileReader.events)
		end)

		after(function()
			etrace.clear()
			etrace.disable(AsyncFileReader.events)
		end)

		it("should fail if the given path is invalid", function()
			AsyncFileReader:LoadFileContents("does-not-exist")
			uv.run()

			local events = etrace.filter("FILE_REQUEST_FAILED")
			assertEquals(#events, 1)

			assertEquals(events[1].name, "FILE_REQUEST_FAILED")
			assertEquals(events[1].payload.fileSystemPath, "does-not-exist")
			assertEquals(events[1].payload.errorMessage, "ENOENT: no such file or directory: does-not-exist")
		end)

		it("should fail if the given path refers to a directory", function()
			AsyncFileReader:LoadFileContents("Runtime")
			uv.run()

			local events = etrace.filter("FILE_REQUEST_FAILED")
			assertEquals(#events, 1)

			assertEquals(events[1].name, "FILE_REQUEST_FAILED")
			assertEquals(events[1].payload.fileSystemPath, "Runtime")
			assertEquals(events[1].payload.errorMessage, "EISDIR: illegal operation on a directory")
		end)

		it("should read a single chunk if the file isn't large enough to warrant buffering", function()
			AsyncFileReader:LoadFileContents(SMALL_TEST_FILE)
			uv.run()

			local events = etrace.filter("FILE_CHUNK_AVAILABLE")
			local numExpectedChunks = 1
			assertEquals(#events, numExpectedChunks)

			assertEquals(events[1].name, "FILE_CHUNK_AVAILABLE")
			assertEquals(events[1].payload.cursorPosition, 1)
			assertEquals(events[1].payload.chunk, "A")
			assertEquals(events[1].payload.fileSystemPath, SMALL_TEST_FILE)
			assertEquals(events[1].payload.lastChunkIndex, 1)
			assertEquals(events[1].payload.chunkIndex, 1)
		end)

		it("should read multiple chunks if the file is large enough to warrant buffering", function()
			AsyncFileReader:LoadFileContents(LARGE_TEST_FILE)
			uv.run()

			local events = etrace.filter("FILE_CHUNK_AVAILABLE")
			local numExpectedChunks = 3
			assertEquals(#events, numExpectedChunks)

			assertEquals(events[1].name, "FILE_CHUNK_AVAILABLE")
			assertEquals(events[1].payload.cursorPosition, 2)
			assertEquals(events[1].payload.chunk, "AA")
			assertEquals(events[1].payload.fileSystemPath, LARGE_TEST_FILE)
			assertEquals(events[1].payload.lastChunkIndex, 3)
			assertEquals(events[1].payload.chunkIndex, 1)

			assertEquals(events[2].name, "FILE_CHUNK_AVAILABLE")
			assertEquals(events[2].payload.cursorPosition, 4)
			assertEquals(events[2].payload.chunk, "AA")
			assertEquals(events[2].payload.fileSystemPath, LARGE_TEST_FILE)
			assertEquals(events[2].payload.lastChunkIndex, 3)
			assertEquals(events[2].payload.chunkIndex, 2)

			assertEquals(events[3].name, "FILE_CHUNK_AVAILABLE")
			assertEquals(events[3].payload.cursorPosition, 5)
			assertEquals(events[3].payload.chunk, "A")
			assertEquals(events[3].payload.fileSystemPath, LARGE_TEST_FILE)
			assertEquals(events[3].payload.lastChunkIndex, 3)
			assertEquals(events[3].payload.chunkIndex, 3)
		end)
	end)
end)

C_FileSystem.Delete(SMALL_TEST_FILE)
C_FileSystem.Delete(LARGE_TEST_FILE)
AsyncFileReader.CHUNK_SIZE_IN_BYTES = OLD_CHUNK_SIZE
