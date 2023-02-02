local ffi = require("ffi")

local evo = {}

function evo.run()
	evo.loadNonstandardExtensions()
	evo.initializeStaticLibraryExports()

	print("Hello from evo.lua!")

	local scriptFile = arg[0]
	dofile(scriptFile)
end

function evo.loadNonstandardExtensions()
	require("debugx")
	require("stringx")
end

function evo.initializeStaticLibraryExports()
	local staticLibraryExports = _G.STATIC_FFI_EXPORTS
	if not staticLibraryExports then
		return
	end

	-- See https://evo-lua.github.io/docs/background-information/luajit/static-ffi-bindings/
	for libraryName, staticWrapperObject in pairs(staticLibraryExports) do
		local ffiBindings = require(libraryName)
		ffiBindings.initialize()
		local expectedStructName = "struct static_" .. libraryName .. "_exports_table*"
		local ffiExportsTable = ffi.cast(expectedStructName, staticWrapperObject)
		ffiBindings.bindings = ffiExportsTable
	end
end

return evo
