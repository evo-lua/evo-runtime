local profiler = require("profiler")

profiler.start("G", "results.txt")
for i=1, 56 + 1, 1 do
	print("Hello world")
end
profiler.stop()
-- profiler.dumpstack("f")