local ffi = require("ffi")

local runtime = {}

runtime.cdefs = [[
	struct static_runtime_exports_table {
		// Build configuration
		const char* (*runtime_version)(void);

		// REPL
		void (*runtime_repl_start)(void);
	};
]]

function runtime.initialize()
	ffi.cdef(runtime.cdefs)
end

function runtime.version()
	local cStringPointer = runtime.bindings.runtime_version()
	local versionString = ffi.string(cStringPointer)

	local majorVersion, minorVersion, patchVersion = versionString:match("(%d+)%.(%d+)%.*(%d*)")
	return versionString, tonumber(majorVersion), tonumber(minorVersion), tonumber(patchVersion)
end

return runtime
