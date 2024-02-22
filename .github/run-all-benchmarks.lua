local transform = require("transform")

local availableBenchmarks = C_FileSystem.ReadDirectoryTree("Benchmarks")
for fileSystemPath, _ in pairs(availableBenchmarks) do
	printf("Running benchmark: %s", transform.brightMagenta(fileSystemPath))
	dofile(fileSystemPath)
	print()
end