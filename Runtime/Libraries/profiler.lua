-- Preloading these modules with their original name allows embedding the LuaJIT profiler extension as-is
package.loaded["jit.vmdef"] = require("vmdef")
package.loaded["jit.zone"] = require("zone") -- Optionally required by jit.p
package.loaded["jit.p"] = require("p") -- Requires jit.vmdef

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
