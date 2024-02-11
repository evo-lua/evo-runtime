local bindings = require("bindings")
local ffi = require("ffi")

local tonumber = tonumber
local format = string.format

local rml = {}

function rml.initialize()
	ffi.cdef(bindings.rml.cdefs)
end

function rml.version()
	local cStringPointer = rml.bindings.rml_version()
	local versionString = ffi.string(cStringPointer)

	local versionMajor, versionMinor, versionPatch = versionString:match("(%d+)%.(%d+)%.*(%d*)")
	versionPatch = versionPatch ~= "" and versionPatch or "0"

	local semanticVersionString =
		format("%d.%d.%d", tonumber(versionMajor), tonumber(versionMinor), tonumber(versionPatch))
	return semanticVersionString
end

return rml
