local bindings = require("bindings")
local ffi = require("ffi")

local labsound = {}

labsound.cdefs = [[
	// Opaque to LuaJIT
	typedef void* labsound_audio_device_t;
	typedef void* labsound_audio_context_t;
	typedef void* labsound_destination_node_t;
	typedef void* labsound_gain_node_t;
	typedef void* labsound_panner_node_t;
	typedef void* labsound_sampled_audio_node_t;
	typedef void* labsound_audio_node_t;

]] .. bindings.labsound.cdefs

function labsound.initialize()
	ffi.cdef(labsound.cdefs)
end

function labsound.version()
	return ffi.string(labsound.bindings.labsound_version())
end

return labsound
