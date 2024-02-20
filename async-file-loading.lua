local AsyncFileReader = C_FileSystem.AsyncFileReader

local etrace = require("etrace")

local filesToLoad = {
	"README.md",
	".gitmodules",
	"LICENSE",
	-- "does-not-exist" -- Uncomment to test error handling
}

local MyApp = {}

function MyApp:ASYNC_GATHER_COMPLETED(event, payload)
	printf("Finished gathering %d file(s)", table.count(payload.completedRequests))
end

etrace.subscribe("ASYNC_GATHER_COMPLETED", MyApp)

printf("Asynchronously loading %d files", #filesToLoad)
AsyncFileReader:GatherFileContents(filesToLoad)

print("Fence reached: Starting the event loop")
-- uv.run()
-- print("Fence surpassed: Event loop has returned")
