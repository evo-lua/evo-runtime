local ffi = require("ffi")
local uv = require("uv")

local runtime = {
	signals = {},
}

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

	-- An unhandled SIGPIPE error signal will crash servers on platforms that send it
	-- This frequently happens when attempting to write to a closed socket and must be ignored
	if uv.constants.SIGPIPE then
		local sigpipeSignal = uv.new_signal()
		sigpipeSignal:start("sigpipe")
		uv.unref(sigpipeSignal)
		runtime.signals.SIGPIPE = sigpipeSignal
	end
end

function runtime.version()
	local cStringPointer = runtime.bindings.runtime_version()
	local versionString = ffi.string(cStringPointer)

	local majorVersion, minorVersion, patchVersion = versionString:match("(%d+)%.(%d+)%.*(%d*)")
	return versionString, tonumber(majorVersion), tonumber(minorVersion), tonumber(patchVersion)
end

return runtime
