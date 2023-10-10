-- TBD globals/EVO_VERSION? aliases? nonstandard extensions? 

local FileSystemAPI = {
	type = "Namespace", -- TBD
	isUnsafe = false, -- FFI tag - apply to only functions/types if e.g. GLFW gets Lua and FFI bindings?
	displayName = "C_FileSystem", -- TODO title, sync, derive?
	summaryLine = "Usability-focused abstraction of the underlying file system APIs",
	status = "Experimental", -- TODO enum stable, experimental, deprecated, external
	availability = "Global", -- TODO enum, derive? (global, preloaded), extensions
	functions = {
		require("Definitions.FileSystem.AppendFile"),
		-- TBD what if just link to externals, e.g. inspect or luv?
	},
	enums = {
		-- GLFW, WebGPU, ...TBD ffi.C vs LE const?
	},
	classes = {
		-- BinaryReader, WebSocketServer, Deflator, ...
	},
	tables = {
		-- path.posix, path.win32
	},
	fields = {
		-- uuid - maybe constants? see globals , EVO_VERSION, STATIC_FFI_EXPORTS
	},
	nativeBindings = {
		-- GLFW.. prob remove and just list functions?
	},
	changelog = {
		-- map of version to entry?
		["v0.0.1"] = "Initial release",
		["v0.0.3"] = "Added `ReadDirectoryTree`",
		["v0.0.4"] = "Added `MakeDirectoryTree`",
	},
}

return FileSystemAPI
