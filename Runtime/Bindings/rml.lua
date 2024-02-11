local bindings = require("bindings")
local ffi = require("ffi")

local tonumber = tonumber
local format = string.format

local rml = {}

rml.cdefs = [[
	typedef void* SystemInterface_GLFW;
	typedef void* RenderInterface_WebGPU;

	typedef void* rml_context_t;
	typedef void* rml_document_t;
	typedef void* wgpu_device_t;
	typedef void* deferred_event_queue_t;
	typedef void* rml_compiled_geometry_t;
	typedef void* glfw_window_t;

	typedef void* rml_compiled_geometry_t;

]] .. bindings.rml.cdefs

function rml.initialize()
	ffi.cdef(rml.cdefs)
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
