local AsyncFileReader = require("Runtime.API.FileSystem.AsyncFileReader") -- C_FileSystem.AsyncFileReader

local console = require("console")

console.startTimer("Generating test fixtures")
local SAMPLE_SIZE = 100000000
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
		local label = "[SYNC] Loading a small file repeatedly, many times"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			-- bitceil_lua(i)
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[ASYNC] Loading a small file repeatedly, many times"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			-- bit.ceil(i)
		end
		console.stopTimer(label)
	end,
}

local function shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

shuffle(availableBenchmarks)

for _, benchmark in ipairs(availableBenchmarks) do
	benchmark()
end

console.startTimer("Removing test fixtures")
C_FileSystem.Delete(SMALL_FILE_PATH)
C_FileSystem.Delete(LARGE_FILE_PATH)
C_FileSystem.Delete(HUGE_FILE_PATH)
console.stopTimer("Removing test fixtures")