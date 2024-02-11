local bindings = require("bindings")
local ffi = require("ffi")

local interop = {}

interop.cdefs = [[
	// Opaque to LuaJIT
	typedef void* wgpu_buffer_t;
	typedef void* wgpu_texture_t;

	typedef void* deferred_event_queue_t; // Duplicated in glfw.cdefs (fix later)

]] .. bindings.interop.cdefs

function interop.initialize()
	ffi.cdef(interop.cdefs)
end

return interop
