-- local profiler = require("jit.p")
local profiler = require("profiler")

-- profiler.start("G", "results.txt")
profiler.start()
for i=1, 56 + 1, 1 do
	local license = C_FileSystem.ReadFile("LICENSE")
	print(license)
end
profiler.stop()
-- profiler.dumpstack("f")