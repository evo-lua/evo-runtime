local bindings = require("bindings")
local ffi = require("ffi")

local uws = {}

uws.cdefs = [[
	typedef void* uws_webserver_t;
]] .. bindings.uws.cdefs

function uws.initialize()
	ffi.cdef(uws.cdefs)
end

function uws.version()
	return ffi.string(uws.bindings.uws_version())
end

return uws
