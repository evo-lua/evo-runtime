local bdd = require("bdd")
local ffi = require("ffi")
local jit = require("jit")
local json = require("json")
local openssl = require("openssl")
local stduuid = require("stduuid")
local uv = require("uv")
local uws = require("uws")
local webview = require("webview")
local zlib = require("zlib")

local format = string.format
local getmetatable = getmetatable
local setmetatable = setmetatable
local pairs = pairs
local type = type

local evo = {
	signals = {},
}

function evo.run()
	evo.loadNonstandardExtensions()
	evo.initializeStaticLibraryExports()
	evo.registerGlobalAliases()
	evo.initializeGlobalNamespaces()
	evo.createSignalHandlers()
	evo.setUpCommandLineInterface()

	C_CommandLine.ProcessArguments(arg)
end

function evo.loadNonstandardExtensions()
	require("debugx")
	require("jsonx")
	require("stringx")
	require("tablex")
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
	_G.path = require("path")

	_G.after = bdd.after
	_G.before = bdd.before
	_G.describe = bdd.describe
	_G.dump = debug.dump
	_G.format = string.format
	_G.it = bdd.it

	_G.printf = evo.printf
	_G.extend = evo.extend
end

function evo.initializeGlobalNamespaces()
	_G.C_CommandLine = require("C_CommandLine")
	_G.C_FileSystem = require("C_FileSystem")
	require("C_Runtime")
	_G.C_Timer = require("C_Timer")
	_G.C_WebView = require("C_WebView")
end

function evo.createSignalHandlers()
	-- An unhandled SIGPIPE error signal will crash servers on platforms that send it, e.g. when attempting to write to a closed socket
	if uv.constants.SIGPIPE then
		local sigpipeSignal = uv.new_signal()
		sigpipeSignal:start("sigpipe")
		uv.unref(sigpipeSignal)
		evo.signals.SIGPIPE = sigpipeSignal
	end
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

	-- Should use OPENSSL_VERSION_* defines here (not currently exposed via lua-openssl)
	local _, _, opensslVersionString = openssl.version()
	local sslVersion = opensslVersionString:match("OpenSSL%s(%d+%.%d+%.%d+)%s.*")

	local embeddedLibraryVersions = {
		libuv = uv.version_string(),
		json = json.version(),
		openssl = sslVersion,
		stduuid = stduuid.version(),
		uws = uws.version(),
		webview = webview.version(),
		zlib = format("%d.%d.%d", zlib.version()),
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

function evo.extend(child, parent)
	local parentMetatable = getmetatable(parent)

	if type(parentMetatable) ~= "table" then
		setmetatable(parent, {})
		parentMetatable = getmetatable(parent)
	end

	local childMetatable = {}
	for key, value in pairs(parentMetatable) do
		childMetatable[key] = value
	end

	childMetatable.__index = parent

	setmetatable(child, childMetatable)
end

return evo
