local bdd = require("bdd")
local ffi = require("ffi")
local jit = require("jit")
local openssl = require("openssl")
local uv = require("uv")
local webview = require("webview")

local format = string.format

local evo = {}

function evo.run()
	evo.loadNonstandardExtensions()
	evo.initializeStaticLibraryExports()
	evo.registerGlobalAliases()
	evo.initializeGlobalNamespaces()
	evo.setUpCommandLineInterface()

	C_CommandLine.ProcessArguments(arg)
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
	_G.C_CommandLine = require("C_CommandLine")
	require("C_Runtime")
end

function evo.setUpCommandLineInterface()
	C_CommandLine.RegisterCommand("help", evo.displayHelpText, "Display usage instructions (this text)")
	C_CommandLine.RegisterCommand("version", evo.showVersionStrings, "Show versioning information")
	C_CommandLine.RegisterCommand("eval", evo.evaluateChunk, "Evaluate the next token as a Lua chunk")
	C_CommandLine.SetDefaultHandler(evo.onInvalidCommand)
end

function evo.displayHelpText(commandName, ...)
	local helpText = format(
		[[
Usage: evo [ script.lua | command ... ]

Commands:

%s]],
		C_CommandLine.GetUsageInfo()
	)
	print(helpText)
	evo.showVersionStrings()
end

function evo.showVersionStrings(commandName, ...)
	local versionText = format("This is Evo.lua %s (powered by %s)", EVO_VERSION, jit.version) .. "\n\n"

	local luaOpensslVersionString, _, opensslVersionString = openssl.version()

	local embeddedLibraryVersions = {
		libuv = uv.version_string(),
		openssl = opensslVersionString .. "(via lua-openssl " .. luaOpensslVersionString .. ")",
		webview = webview.version(),
	}
	versionText = versionText .. "Embedded libraries:\n\n"
	for libraryName, versionString in pairs(embeddedLibraryVersions) do
		versionText = versionText .. "\t" .. format("%-10s", libraryName) .. "\t" .. versionString .. "\n"
	end

	print(versionText)
	print("For documentation and examples, visit https://evo-lua.github.io/")
end

function evo.evaluateChunk(commandName, argv)
	local luaCodeToEvaluate = unpack(argv)

	if not luaCodeToEvaluate then
		return
	end

	local chunk = load(luaCodeToEvaluate)
	if not chunk then
		return
	end

	chunk()
end

function evo.onInvalidCommand(command)
	local isLuaScript = string.match(string.lower(command), ".*%.lua")
	if isLuaScript then
		return dofile(command)
	end

	if command ~= "" then
		print("Invalid command: " .. command .. "\n")
	end

	evo.displayHelpText()
end

function evo.printf(...)
	return print(format(...))
end

return evo
