local bindings = require("bindings")
local ffi = require("ffi")

local uws = {}

function uws.initialize()
	ffi.cdef(bindings.uws.cdefs)
end

function uws.version()
	return ffi.string(uws.bindings.uws_version())
end

return uws
