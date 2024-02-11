local bindings = require("bindings")
local ffi = require("ffi")

local stduuid = {}

function stduuid.initialize()
	ffi.cdef(bindings.stduuid.cdefs)
end

function stduuid.version()
	-- Hardcoded because of laziness (may automate tag discovery later)
	return "1.2.3"
end

return stduuid
