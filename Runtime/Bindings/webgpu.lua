local ffi = require("ffi")
local bindings = require("bindings")

local wgpu = {}

function wgpu.initialize()
	ffi.cdef(bindings.webgpu.cdefs)
end

function wgpu.version()
	return ffi.string(wgpu.bindings.wgpu_version())
end

return wgpu
