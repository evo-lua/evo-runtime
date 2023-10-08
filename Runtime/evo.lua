local bdd = require("bdd")
local console = require("console")
local crypto = require("crypto")
local ffi = require("ffi")
local glfw = require("glfw")
local jit = require("jit")
local json = require("json")
local miniz = require("miniz")
local regex = require("regex")
local stbi = require("stbi")
local stduuid = require("stduuid")
local uv = require("uv")
local uws = require("uws")
local vfs = require("vfs")
local webgpu = require("webgpu")
local webview = require("webview")
local zlib = require("zlib")

local format = string.format
local table_insert = table.insert
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

	local zipApp = evo.readEmbeddedZipApp()
	if zipApp then
		return vfs.dofile(zipApp, "main.lua")
	end

	evo.setUpCommandLineInterface()
	return C_CommandLine.ProcessArguments(arg)
end

function evo.readEmbeddedZipApp()
	local executableBytes = C_FileSystem.ReadFile(uv.exepath())
	return vfs.decode(executableBytes)
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

	_G.printf = console.printf
	_G.extend = evo.extend

	_G.cdef = ffi.cdef
	_G.define = ffi.cdef
	_G.cast = ffi.cast
	_G.new = ffi.new
	_G.sizeof = ffi.sizeof
	_G.typeof = ffi.typeof
end

function evo.initializeGlobalNamespaces()
	_G.C_CommandLine = require("C_CommandLine")
	_G.C_FileSystem = require("C_FileSystem")
	_G.C_ImageProcessing = require("C_ImageProcessing")
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
	C_CommandLine.RegisterCommand("version", evo.displayRuntimeVersion, "Show versioning information only")
	C_CommandLine.RegisterCommand("eval", evo.evaluateChunk, "Evaluate the next token as a Lua chunk")
	C_CommandLine.RegisterCommand("build", evo.buildZipApp, "Create a self-contained executable")

	C_CommandLine.SetAlias("help", "-h")
	C_CommandLine.SetAlias("version", "-v")
	C_CommandLine.SetAlias("eval", "-e")
	C_CommandLine.SetAlias("build", "-b")

	C_CommandLine.SetDefaultHandler(evo.onInvalidCommand)
end

function evo.displayHelpText(commandName, ...)
	local helpText = evo.getHelpText()
	print(helpText)
	evo.showVersionStrings()
end

function evo.getHelpText()
	local helpText = format(
		[[
Usage: evo [ script.lua | command ] ...

Commands:

%s]],
		C_CommandLine.GetUsageInfo()
	)
	return helpText
end

function evo.displayRuntimeVersion(commandName, ...)
	print(EVO_VERSION)
end

function evo.showVersionStrings(commandName, ...)
	local versionText = evo.getVersionText()

	print(versionText)
	print("For documentation and examples, visit https://evo-lua.github.io/")
end

function evo.getVersionText()
	local versionText = format("This is Evo.lua %s (powered by %s)", EVO_VERSION, jit.version) .. "\n\n"

	-- The format exposed by PCRE2 is not consistent with the other libraries (no patch version, date suffix)
	local major, minor = string.match(regex.version(), "^(%d+)%.(%d+)")
	local semanticPcre2VersionString = major .. "." .. minor .. "." .. 0

	local embeddedLibraryVersions = {
		glfw = glfw.version(),
		libuv = uv.version_string(),
		miniz = miniz.version(),
		rapidjson = json.version(),
		openssl = crypto.version(),
		pcre2 = semanticPcre2VersionString,
		stbi = stbi.version(),
		stduuid = stduuid.version(),
		uws = uws.version(),
		wgpu = webgpu.version(),
		webview = webview.version(),
		zlib = format("%d.%d.%d", zlib.version()),
		-- Since the ordering of pairs isn't well-defined, enforce alphabetic order for the CLI output
		"glfw",
		"libuv",
		"miniz",
		"openssl",
		"pcre2",
		"rapidjson",
		"stbi",
		"stduuid",
		"uws",
		"webview",
		"wgpu",
		"zlib",
	}
	versionText = versionText .. "Embedded libraries:\n\n"
	for index, libraryName in ipairs(embeddedLibraryVersions) do
		local versionString = embeddedLibraryVersions[libraryName]
		versionText = versionText .. "\t" .. format("%-10s", libraryName) .. "\t" .. versionString .. "\n"
	end

	return versionText
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

function evo.buildZipApp(commandName, argv)
	local isWindows = ffi.os == "Windows"
	local suffix = isWindows and ".exe" or ""
	local inputDirectory = argv[1] or uv.cwd()

	local outputFileName = path.basename(inputDirectory) .. suffix
	if not C_FileSystem.Exists(inputDirectory) or not C_FileSystem.IsDirectory(inputDirectory) then
		printf("Cannot create self-contained executable: %s", outputFileName)
		printf("Not a directory: %s", inputDirectory)
		print("Please make sure a directory with this name exists (and contains main.lua)")
		return
	end

	if #argv == 0 then
		print("No inputs given, building from the current working directory")
	else
		print("Building from " .. path.resolve(inputDirectory))
	end

	local expectedEntryPoint = path.join(inputDirectory, "main.lua")
	local hasEntryPoint = C_FileSystem.Exists(expectedEntryPoint)
	if not hasEntryPoint then
		printf("Cannot create self-contained executable: %s", outputFileName)
		print("main.lua not found - without an entry point, your app won't be able to run!")
		return
	end

	local zipWriter = miniz.new_writer()
	local MAX_COMPRESSION_LEVEL = 9

	local files = C_FileSystem.ReadDirectoryTree(inputDirectory)
	-- Sort the files so that the output is deterministic (and testable)
	local orderedFiles = {}
	for k in pairs(files) do
		table_insert(orderedFiles, k)
	end
	table.sort(orderedFiles)

	local numFilesAdded = 0
	local numBytesAdded = 0
	for index, filePath in ipairs(orderedFiles) do
		local relativePath = path.relative(inputDirectory, filePath)
		local fileContents = C_FileSystem.ReadFile(filePath)
		zipWriter:add(relativePath, fileContents, MAX_COMPRESSION_LEVEL)

		numBytesAdded = numBytesAdded + #fileContents
		numFilesAdded = numFilesAdded + 1

		printf("Adding file: %s", relativePath)
	end
	local zipFileContents = zipWriter:finalize()
	printf(
		"Archived %d files (%s) - total size: %s",
		numFilesAdded,
		string.filesize(numBytesAdded),
		string.filesize(#zipFileContents)
	)

	local archiveFilePath = path.basename(inputDirectory) .. ".zip"
	C_FileSystem.WriteFile(archiveFilePath, zipFileContents)
	print("Created miniz archive: " .. archiveFilePath)

	local runtimeFileContents = C_FileSystem.ReadFile(uv.exepath())
	local signature = ffi.new("lua_zip_signature_t")
	signature.magicValue = "LUAZIP"
	signature.versionMajor = 1
	signature.versionMinor = 0
	signature.executableSize = #runtimeFileContents
	signature.archiveSize = #zipFileContents
	printf(
		"Embedding signature: LUAZIP %d.%d (EXE: %d, ZIP: %d)",
		tonumber(signature.versionMajor),
		tonumber(signature.versionMinor),
		tonumber(signature.executableSize),
		tonumber(signature.archiveSize)
	)

	local standaloneExecutableBytes = runtimeFileContents
		.. zipFileContents
		.. ffi.string(signature, ffi.sizeof(signature))
	C_FileSystem.WriteFile(outputFileName, standaloneExecutableBytes)
	printf("Created self-contained executable: %s", outputFileName)
end

function evo.onInvalidCommand(command, argv)
	local isLuaScript = string.match(string.lower(command), ".*%.lua")
	if isLuaScript then
		return dofile(command)
	end

	if command ~= "" then
		print("Invalid command: " .. command .. "\n")
	end

	evo.displayHelpText()
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
