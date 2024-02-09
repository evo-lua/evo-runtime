local ffi = require("ffi")

local runtime = {}

runtime.cdefs = [[
	struct static_runtime_exports_table {
		// REPL
		void (*runtime_repl_start)(void);
	};
]]

function runtime.initialize()
	ffi.cdef(runtime.cdefs)
end

return runtime
