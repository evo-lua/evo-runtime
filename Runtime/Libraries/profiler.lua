local p = require("jit.p")
local zone = require("jit.zone")

local profiler = {}

profiler.start = p.start
profiler.stop = p.stop
profiler.zone = zone

assert(profiler.start)
assert(profiler.stop)
assert(profiler.zone)

return profiler
