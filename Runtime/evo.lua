local bdd = require("bdd")
local ffi = require("ffi")

local format = string.format

local evo = {}

function evo.run()
	evo.loadNonstandardExtensions()
	evo.initializeStaticLibraryExports()
	evo.registerGlobalAliases()
	evo.initializeGlobalNamespaces()

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

function evo.registerGlobalAliases()
	_G.buffer = require("string.buffer")
	_G.describe = bdd.describe
	_G.dump = debug.dump
	_G.format = string.format
	_G.it = bdd.it

	_G.printf = evo.printf
end

function evo.initializeGlobalNamespaces()
	require("C_Runtime")
end

function evo.printf(...)
	return print(format(...))
end

return evo
