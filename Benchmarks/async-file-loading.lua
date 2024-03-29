local AsyncFileReader = require("AsyncFileReader")

local console = require("console")
local uv = require("uv")

console.startTimer("Generating test fixtures")
local SAMPLE_SIZE = 250
local SMALL_FILE_PATH = path.join("Tests", "Fixtures", "test-small.txt")
local LARGE_FILE_PATH = path.join("Tests", "Fixtures", "test-large.txt")
local HUGE_FILE_PATH = path.join("Tests", "Fixtures", "test-huge.txt")
local SMALL_FILE_SIZE_IN_BYTES = math.min(AsyncFileReader.CHUNK_SIZE_IN_BYTES - 1, 32)
local LARGE_FILE_SIZE_IN_BYTES = 4 * AsyncFileReader.CHUNK_SIZE_IN_BYTES + 1
local HUGE_FILE_SIZE_IN_BYTES = 1024 * 1024 * 32
local SMALL_FILE_CONTENTS = string.rep("A", SMALL_FILE_SIZE_IN_BYTES)
local LARGE_FILE_CONTENTS = string.rep("A", LARGE_FILE_SIZE_IN_BYTES)
local HUGE_FILE_CONTENTS = string.rep("A", HUGE_FILE_SIZE_IN_BYTES)
C_FileSystem.WriteFile(SMALL_FILE_PATH, SMALL_FILE_CONTENTS)
C_FileSystem.WriteFile(LARGE_FILE_PATH, LARGE_FILE_CONTENTS)
C_FileSystem.WriteFile(HUGE_FILE_PATH, HUGE_FILE_CONTENTS)
console.stopTimer("Generating test fixtures")

math.randomseed(os.clock())
local availableBenchmarks = {
	function()
		local label = "[ASYNC] Loading a small file repeatedly, many times"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			AsyncFileReader:LoadFileContents(SMALL_FILE_PATH)
		end
		uv.run()
		console.stopTimer(label)
	end,
	function()
		local label = "[ASYNC] Loading a large file repeatedly, many times"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			AsyncFileReader:LoadFileContents(LARGE_FILE_PATH)
		end
		uv.run()
		console.stopTimer(label)
	end,
	function()
		local label = "[ASYNC] Loading a huge file repeatedly, many times"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			AsyncFileReader:LoadFileContents(HUGE_FILE_PATH)
		end
		uv.run()
		console.stopTimer(label)
	end,
	function()
		local label = "[SYNC] Loading a small file repeatedly, many times"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			C_FileSystem.ReadFile(SMALL_FILE_PATH)
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[SYNC] Loading a large file repeatedly, many times"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			C_FileSystem.ReadFile(LARGE_FILE_PATH)
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[SYNC] Loading a huge file repeatedly, many times"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			C_FileSystem.ReadFile(HUGE_FILE_PATH)
		end
		console.stopTimer(label)
	end,
}

table.shuffle(availableBenchmarks)

for _, benchmark in ipairs(availableBenchmarks) do
	benchmark()
end

console.startTimer("Removing test fixtures")
C_FileSystem.Delete(SMALL_FILE_PATH)
C_FileSystem.Delete(LARGE_FILE_PATH)
C_FileSystem.Delete(HUGE_FILE_PATH)
console.stopTimer("Removing test fixtures")
