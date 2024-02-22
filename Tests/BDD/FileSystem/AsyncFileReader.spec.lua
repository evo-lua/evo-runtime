local etrace = require("etrace")
local uv = require("uv")

local AsyncFileReader = require("Runtime.API.FileSystem.AsyncFileReader") -- C_FileSystem.AsyncFileReader

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
		after(function()
			etrace.clear()
		end)

		it("should visibly fail if the given path is invalid", function()
			AsyncFileReader:LoadFileContents("does-not-exist")
			uv.run()

			local events = etrace.filter("FILE_REQUEST_FAILED")
			assertEquals(#events, 1)

			assertEquals(events[1].name, "FILE_REQUEST_FAILED")
			assertEquals(events[1].payload.fileSystemPath, "does-not-exist")
			assertEquals(events[1].payload.message, "ENOENT: no such file or directory: does-not-exist")
		end)

		it("should visibly fail if the given path refers to a directory", function()
			AsyncFileReader:LoadFileContents("Runtime")
			uv.run()

			local events = etrace.filter("FILE_REQUEST_FAILED")
			assertEquals(#events, 1)

			assertEquals(events[1].name, "FILE_REQUEST_FAILED")
			assertEquals(events[1].payload.fileSystemPath, "Runtime")
			assertEquals(events[1].payload.message, "EISDIR: illegal operation on a directory")
		end)

		it("should read a single chunk if the file isn't large enough to warrant buffering", function()
			AsyncFileReader:LoadFileContents(SMALL_TEST_FILE)
			uv.run()

			local events = etrace.filter("FILE_CHUNK_AVAILABLE")
			local numExpectedChunks = 1
			assertEquals(#events, numExpectedChunks)

			assertEquals(events[1].name, "FILE_CHUNK_AVAILABLE")
			assertEquals(events[1].payload.chunkBytes, "A")
			assertEquals(events[1].payload.fileSystemPath, SMALL_TEST_FILE)
			assertEquals(events[1].payload.maxChunkIndex, 1)
			assertEquals(events[1].payload.currentChunkIndex, 1)
		end)

		it("should read multiple chunks if the file is large enough to warrant buffering", function()
			AsyncFileReader:LoadFileContents(LARGE_TEST_FILE)
			uv.run()

			local events = etrace.filter("FILE_CHUNK_AVAILABLE")
			local numExpectedChunks = 2
			assertEquals(#events, numExpectedChunks)

			assertEquals(events[1].name, "FILE_CHUNK_AVAILABLE")
			assertEquals(events[1].payload.chunkBytes, "AA")
			assertEquals(events[1].payload.fileSystemPath, LARGE_TEST_FILE)
			assertEquals(events[1].payload.maxChunkIndex, 1)
			assertEquals(events[1].payload.currentChunkIndex, 2)

			assertEquals(events[2].name, "FILE_CHUNK_AVAILABLE")
			assertEquals(events[2].payload.chunkBytes, "AA")
			assertEquals(events[2].payload.fileSystemPath, LARGE_TEST_FILE)
			assertEquals(events[2].payload.maxChunkIndex, 2)
			assertEquals(events[2].payload.currentChunkIndex, 2)
		end)
	end)
end)

-- tbd what if the same file is read, queue up or just wait until one request and return the result?
-- tbd what if write/read interleaves? should be handled by libuv, in order?
-- what if file is deleted while reading chunks? probably impossible, uv threads block?
-- TODO benchmark

C_FileSystem.Delete(SMALL_TEST_FILE)
C_FileSystem.Delete(LARGE_TEST_FILE)
AsyncFileReader.CHUNK_SIZE_IN_BYTES = OLD_CHUNK_SIZE
