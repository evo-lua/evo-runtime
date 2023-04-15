local ffi = require("ffi")

local uws = {}

uws.cdefs = [[
	typedef struct static_uws_exports_table {
		const char* (*uws_version)(void);
	} static_uws_exports_table;
]]

function uws.initialize()
	ffi.cdef(uws.cdefs)
end

function uws.version()
	return ffi.string(uws.bindings.uws_version())
end

return uws
