local bindings = require("bindings")
local ffi = require("ffi")

local labsound = {}

function labsound.initialize()
	ffi.cdef(bindings.labsound.cdefs)
end

function labsound.version()
	return ffi.string(labsound.bindings.labsound_version())
end

return labsound
