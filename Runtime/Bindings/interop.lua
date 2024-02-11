local bindings = require("bindings")
local ffi = require("ffi")

local interop = {}

function interop.initialize()
	ffi.cdef(bindings.interop.cdefs)
end

return interop
