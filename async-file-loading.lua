-- local AsyncFileReader = C_FileSystem.AsyncFileReader
local AsyncFileReader = require("Runtime.API.FileSystem.AsyncFileReader") -- C_FileSystem.AsyncFileReader

local etrace = require("etrace")

local filesToLoad = {
	"README.md",
	".gitmodules",
	"LICENSE",
	-- "does-not-exist" -- Uncomment to test error handling
}

local lotsOfFiles = C_FileSystem.ReadDirectoryTree("deps")
filesToLoad = table.keys(lotsOfFiles)

-- error(table.count(filesToLoad)) -- 80k files, let's go

local MyApp = {}

function MyApp:FILE_CONTENTS_AVAILABLE(event, payload)
	-- printf("FILE_CONTENTS_AVAILABLE: %s", payload.fileSystemPath)
end

function MyApp:ASYNC_GATHER_COMPLETED(event, payload)
	printf("Finished gathering %d file(s)", table.count(payload.completedRequests))
end

etrace.subscribe("FILE_CONTENTS_AVAILABLE", MyApp)
etrace.subscribe("ASYNC_GATHER_COMPLETED", MyApp)

printf("Asynchronously loading %d files", #filesToLoad)
-- for index, fileSystemPath in pairs(filesToLoad) do	AsyncFileReader:LoadFileContents(fileSystemPath) end
for index, fileSystemPath in pairs(filesToLoad) do	C_FileSystem.ReadFile(fileSystemPath) end
-- TBD coro-fs also worth checking out?
-- AsyncFileReader:GatherFileContents(filesToLoad)

print("Fence reached: Starting the event loop")
-- uv.run()
-- print("Fence surpassed: Event loop has returned")
