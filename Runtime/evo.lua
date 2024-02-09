local assertions = require("assertions")
local bdd = require("bdd")
local console = require("console")
local crypto = require("crypto")
local etrace = require("etrace")
local ffi = require("ffi")
local glfw = require("glfw")
local jit = require("jit")
local json = require("json")
local labsound = require("labsound")
local lpeg = require("lpeg")
local miniz = require("miniz")
local oop = require("oop")
local profiler = require("profiler")
local regex = require("regex")
local rml = require("rml")
local runtime = require("runtime")
local stbi = require("stbi")
local stduuid = require("stduuid")
local syslog = require("syslog")
local transform = require("transform")
local uv = require("uv")
local uws = require("uws")
local vfs = require("vfs")
local webgpu = require("webgpu")
local webview = require("webview")
local versions = require("versions")
local zlib = require("zlib")

local format = string.format
local table_insert = table.insert
local pairs = pairs

local EXIT_FAILURE = 1
local EXPECTED_TEST_RUNNER_ENTRY_POINT = "test.lua"
local EXPECTED_APP_BUNDLER_ENTRY_POINT = "main.lua"
local GITHUB_DOCS_URL = "https://evo-lua.github.io/"

local evo = {
	signals = {},
	embeddedLibraryVersions = versions,
	-- Interpreter CLI
	DEFAULT_ENTRY_POINT = EXPECTED_APP_BUNDLER_ENTRY_POINT,
	DEFAULT_TEST_SCRIPT = EXPECTED_TEST_RUNNER_ENTRY_POINT,
	GITHUB_DOCS_URL = GITHUB_DOCS_URL,
	errorStrings = {
		TEST_RUNNER_ENTRY_POINT_MISSING = format(
			"Cannot start test runner in the current directory (entry point %s not found)",
			EXPECTED_TEST_RUNNER_ENTRY_POINT
		),
		TEST_RUNNER_CANNOT_OPEN = "Cannot open %s: No such file or directory",
		TEST_RUNNER_CANNOT_LOAD = "Cannot load %s: Not a .lua script (wrong file extension?)",
		APP_BUNDLER_ENTRY_POINT_MISSING = "Cannot create self-contained executable: %s (entry point %s not found)",
		APP_BUNDLER_INVALID_BUILD_DIR = "Cannot create self-contained executable: %s (entry point %s is not a directory)",
	},
	messageStrings = {
		HELP_COMMAND_DOCUMENTATION_LINK = format(
			"For documentation and examples, visit %s",
			transform.brightGreen(GITHUB_DOCS_URL)
		),
		TEST_COMMAND_USAGE_INFO = format(
			[[To run automated tests with this command, you can:

* Provide %s files that should be run as tests: %s
* Provide directory paths that include %s test files to run: %s
* Provide a %s file that starts your test suite in any way you see fit: %s (no arguments)

All scripts loaded in this mode will have global access to functions in the %s library.]],
			transform.bold(".lua"),
			transform.brightYellow("evo test testFile1.lua testFile2.lua ... testFileN.lua"),
			transform.bold(".lua"),
			transform.brightYellow("evo test testDir1 testDir2 ... testDirN"),
			transform.bold(EXPECTED_TEST_RUNNER_ENTRY_POINT),
			transform.brightYellow("evo test"),
			transform.brightBlue("assertions")
		),
		BUILD_COMMAND_USAGE_INFO = format(
			[[To build standalone applications with this command, you can:

* Provide the directory that contains your code (and %s) to build from: %s
* Provide a %s file that initializes your program in any way you see fit: %s

Running the bundled app will always load %s with the version of the runtime used to create it.]],
			transform.bold(EXPECTED_APP_BUNDLER_ENTRY_POINT),
			transform.brightYellow("evo build appDir"),
			transform.bold(EXPECTED_APP_BUNDLER_ENTRY_POINT),
			transform.brightYellow("evo build"),
			transform.brightBlue(EXPECTED_APP_BUNDLER_ENTRY_POINT)
		),
		PROFILE_COMMAND_USAGE_INFO = format(
			[[To identify performance issues with the help of this command, you can:

* Provide the path to a %s program and additional arguments that it should receive: %s
* Provide any valid combination of profiler options via mode flags: %s
* Provide an optional file name to save the profiling results: %s

A list of supported profiling modes and their combinations can be found here: %s]],
			transform.bold(".lua"),
			transform.brightYellow("evo profile script.lua ..."),
			transform.brightYellow("LUAJIT_PROFILEMODE=3si4m1 evo profile script.lua ..."),
			transform.brightYellow("LUAJIT_PROFILEFILE=results.txt evo profile script.lua ..."),
			transform.brightBlue("https://luajit.org/ext_profiler.html")
		),
	},
}

function evo.run()
	evo.loadNonstandardExtensions()
	evo.initializeStaticLibraryExports()
	evo.registerGlobalAliases()
	evo.initializeGlobalNamespaces()
	evo.createSignalHandlers()

	local zipApp = evo.readEmbeddedZipApp()
	if zipApp then
		-- The CLI args are shifted if not run from the interpreter CLI, which might break standalone apps
		local correctedArgs = {}
		for index, arg in ipairs(arg) do
			correctedArgs[index + 1] = arg
		end
		correctedArgs[1] = arg[0]
		_G.arg = correctedArgs
		_G.arg[0] = uv.exepath()
		return vfs.dofile(zipApp, evo.DEFAULT_ENTRY_POINT)
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
	-- Can't initialize this table on load as some modules will be missing
	evo.globalAliases = {
		after = bdd.after,
		before = bdd.before,
		buffer = require("string.buffer"),
		cast = ffi.cast,
		cdef = ffi.cdef,
		class = oop.class,
		classname = oop.classname,
		define = ffi.cdef,
		describe = bdd.describe,
		dump = debug.dump,
		extend = oop.extend,
		format = string.format,
		implements = oop.implements,
		instanceof = oop.instanceof,
		it = bdd.it,
		mixin = oop.mixin,
		new = ffi.new,
		path = require("path"),
		printf = console.printf,
		sizeof = ffi.sizeof,
		typeof = ffi.typeof,
		DEBUG = syslog.debug,
		INFO = syslog.info,
		NOTICE = syslog.notice,
		WARNING = syslog.warning,
		ERROR = syslog.error,
		CRITICAL = syslog.critical,
		ALERT = syslog.alert,
		EMERGENCY = syslog.emergency,
		EVENT = etrace.publish,
	}

	for alias, target in pairs(evo.globalAliases) do
		_G[alias] = target
	end
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
	C_CommandLine.RegisterCommand("eval", evo.evaluateChunk, "Evaluate expressions live or from input")
	C_CommandLine.RegisterCommand("build", evo.buildZipApp, "Create a self-contained executable")
	C_CommandLine.RegisterCommand("test", evo.discoverAndRunTests, "Run tests from files or directories")
	C_CommandLine.RegisterCommand("profile", evo.runScriptWhileProfiling, "Enable LuaJIT's built-in CPU profiler")

	C_CommandLine.SetAlias("help", "-h")
	C_CommandLine.SetAlias("version", "-v")
	C_CommandLine.SetAlias("eval", "-e")
	C_CommandLine.SetAlias("build", "-b")
	C_CommandLine.SetAlias("test", "-t")
	C_CommandLine.SetAlias("profile", "-p")

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
%s

Commands:

%s]],
		transform.bold("Usage: evo [ script.lua | command ] ..."),
		transform.brightYellow(C_CommandLine.GetUsageInfo())
	)
	return helpText
end

function evo.displayRuntimeVersion(commandName, ...)
	print(EVO_VERSION)
end

function evo.showVersionStrings(commandName, ...)
	local versionText = evo.getVersionText()

	print(versionText)
	print(evo.messageStrings.HELP_COMMAND_DOCUMENTATION_LINK)
end

function evo.getVersionText()
	local versionText = format(
		"This is %s (powered by %s)",
		transform.brightGreen("Evo.lua " .. EVO_VERSION),
		transform.brightBlue(jit.version)
	) .. "\n\n"

	-- The format exposed by PCRE2 is not consistent with the other libraries (no patch version, date suffix)
	local major, minor = string.match(regex.version(), "^(%d+)%.(%d+)")
	local semanticPcre2VersionString = major .. "." .. minor .. "." .. 0

	-- zlib versions don't include a patch version if it's a clean major/minor release
	local zlibVersionMajor, zlibVersionMinor, zlibVersionPatch = zlib.version()
	local semanticZlibVersionString = format("%d.%d.%d", zlibVersionMajor, zlibVersionMinor, zlibVersionPatch or 0)

	-- LPEG adds its name to the version, as well
	local semanticLpegVersionString = string.match(lpeg.version, "LPeg%s([%d%.]+)")

	local embeddedLibraryVersions = {
		glfw = glfw.version(),
		labsound = labsound.version(),
		libuv = uv.version_string(),
		lpeg = semanticLpegVersionString,
		miniz = miniz.version(),
		rapidjson = json.version(),
		openssl = crypto.version(),
		pcre2 = semanticPcre2VersionString,
		rml = rml.version(),
		stbi = stbi.version(),
		stduuid = stduuid.version(),
		uws = uws.version(),
		wgpu = webgpu.version(),
		webview = webview.version(),
		zlib = semanticZlibVersionString,
		-- Since the ordering of pairs isn't well-defined, enforce alphabetic order for the CLI output
		"glfw",
		"labsound",
		"libuv",
		"lpeg",
		"miniz",
		"openssl",
		"pcre2",
		"rapidjson",
		"rml",
		"stbi",
		"stduuid",
		"uws",
		"webview",
		"wgpu",
		"zlib",
	}
	local submodulePaths = {
		glfw = "deps/glfw/glfw",
		labsound = "deps/LabSound/LabSound",
		libuv = "deps/luvit/luv", -- Always tracks the libuv version
		lpeg = "deps/roberto-ieru/LPeg",
		miniz = "deps/richgel999/miniz",
		rapidjson = "deps/xpol/lua-rapidjson",
		openssl = "deps/openssl/openssl",
		pcre2 = "deps/PCRE2Project/pcre2",
		rml = "deps/mikke89/RmlUi",
		stbi = "deps/nothings/stb",
		stduuid = "deps/mariusbancila/stduuid",
		uws = "deps/uNetworking/uWebSockets",
		wgpu = "deps/gfx-rs/wgpu-native",
		webview = "deps/webview/webview",
		zlib = "deps/madler/zlib",
	}

	versionText = versionText .. "Embedded libraries:\n\n"
	for index, libraryName in ipairs(embeddedLibraryVersions) do
		local versionString = embeddedLibraryVersions[libraryName]
		local submodulePath = submodulePaths[libraryName]
		local commitHash = evo.embeddedLibraryVersions[submodulePath].commit
		versionText = versionText
			.. "\t"
			.. transform.brightBlue(format("%-10s", libraryName))
			.. "\t"
			.. transform.brightBlue(versionString)
			.. "\t\t"
			.. format("%s", transform.brightBlue(commitHash))
			.. "\n"
	end

	return versionText
end

function evo.evaluateChunk(commandName, argv)
	local luaCodeToEvaluate = unpack(argv)

	if not luaCodeToEvaluate then
		printf(transform.brightGreen("Welcome to Evo.lua %s (REPL powered by LuaJIT)"), EVO_VERSION)
		printf(
			"Evaluating code in %s mode. To exit, press %s or type %s.",
			transform.brightMagenta("live edit"),
			transform.brightYellow("CTRL+C"),
			transform.brightYellow("os.exit()")
		)
		runtime.bindings.runtime_repl_start()
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
		printf(transform.brightRed(evo.errorStrings.APP_BUNDLER_INVALID_BUILD_DIR), outputFileName, inputDirectory)
		print()
		print(evo.messageStrings.BUILD_COMMAND_USAGE_INFO)
		os.exit(EXIT_FAILURE)
	end

	if #argv == 0 then
		printf("Building from %s", transform.bold(uv.cwd()))
	else
		printf("Building from %s", transform.bold(path.resolve(inputDirectory)))
	end

	local expectedEntryPoint = path.join(inputDirectory, evo.DEFAULT_ENTRY_POINT)
	local hasEntryPoint = C_FileSystem.Exists(expectedEntryPoint)
	if not hasEntryPoint then
		printf(
			transform.brightRed(evo.errorStrings.APP_BUNDLER_ENTRY_POINT_MISSING),
			outputFileName,
			evo.DEFAULT_ENTRY_POINT
		)
		print()
		print(evo.messageStrings.BUILD_COMMAND_USAGE_INFO)
		os.exit(EXIT_FAILURE)
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

		printf(transform.magenta("Adding file: %s"), relativePath)
	end
	local zipFileContents = zipWriter:finalize()
	printf(
		transform.brightGreen("Archived %d files (%s) - total size: %s"),
		numFilesAdded,
		string.filesize(numBytesAdded),
		string.filesize(#zipFileContents)
	)

	local archiveFilePath = path.basename(inputDirectory) .. ".zip"
	C_FileSystem.WriteFile(archiveFilePath, zipFileContents)
	printf("Created miniz archive: %s", transform.brightYellow(archiveFilePath))

	local runtimeFileContents = C_FileSystem.ReadFile(uv.exepath())
	local signature = ffi.new("lua_zip_signature_t")
	signature.magicValue = "LUAZIP"
	signature.versionMajor = 1
	signature.versionMinor = 0
	signature.executableSize = #runtimeFileContents
	signature.archiveSize = #zipFileContents
	printf(
		transform.brightGreen("Embedding signature: LUAZIP %d.%d (EXE: %d, ZIP: %d)"),
		tonumber(signature.versionMajor),
		tonumber(signature.versionMinor),
		tonumber(signature.executableSize),
		tonumber(signature.archiveSize)
	)

	local standaloneExecutableBytes = runtimeFileContents
		.. zipFileContents
		.. ffi.string(signature, ffi.sizeof(signature))
	C_FileSystem.WriteFile(outputFileName, standaloneExecutableBytes)
	printf("Created self-contained executable: %s", transform.brightYellow(outputFileName))
end

function evo.discoverAndRunTests(command, argv)
	local appArgs = {}
	local preprocessedArgs = {}
	-- Application-specific args (delimited by --) should be passed as-is to allow customizing test.lua runners
	for index, argument in ipairs(argv) do
		local appArg = argument:match("^%-%-(.*)$")
		if appArg then
			table_insert(appArgs, appArg)
		else
			table_insert(preprocessedArgs, argument)
		end
	end

	if #preprocessedArgs == 0 then
		-- Ran test command without any inputs -> Fall back to custom test runner initialization (test.lua hook)
		local hasDefaultEntryPoint = C_FileSystem.Exists(evo.DEFAULT_TEST_SCRIPT)
		if not hasDefaultEntryPoint then
			print(transform.brightRed(evo.errorStrings.TEST_RUNNER_ENTRY_POINT_MISSING))
			print()
			print(evo.messageStrings.TEST_COMMAND_USAGE_INFO)
			os.exit(EXIT_FAILURE)
		end

		_G.arg = appArgs
		assertions.export()
		return dofile(evo.DEFAULT_TEST_SCRIPT)
	end

	-- Ran test command with files or directories as input -> Recursive test discovery mode
	local specFiles = {}
	for index, specFileOrFolder in ipairs(preprocessedArgs) do
		if C_FileSystem.IsDirectory(specFileOrFolder) then
			local directoryTree = C_FileSystem.ReadDirectoryTree(specFileOrFolder)

			local specFilePaths = {}
			-- The order should be well-defined (for predictability/testing purposes), but pairs is not
			for filePath, isFileEntry in pairs(directoryTree) do
				local isLuaScript = (path.extname(filePath) == ".lua")
				if isLuaScript then
					table_insert(specFilePaths, filePath)
				end
			end

			table.sort(specFilePaths)
			for _, filePath in ipairs(specFilePaths) do
				table_insert(specFiles, filePath)
			end
		elseif C_FileSystem.IsFile(specFileOrFolder) then
			local isLuaScript = (path.extname(specFileOrFolder) == ".lua")
			if not isLuaScript then
				print(transform.brightRed(format(evo.errorStrings.TEST_RUNNER_CANNOT_LOAD, specFileOrFolder)))
				os.exit(EXIT_FAILURE)
			end

			table_insert(specFiles, specFileOrFolder)
		else
			print(transform.brightRed(format(evo.errorStrings.TEST_RUNNER_CANNOT_OPEN, specFileOrFolder)))
			os.exit(EXIT_FAILURE)
		end
	end

	local numFailedSections = C_Runtime.RunDetailedTests(specFiles)
	os.exit(numFailedSections, true)
end

function evo.runScriptWhileProfiling(command, argv)
	local profilingModeFlags = os.getenv("LUAJIT_PROFILEMODE")
	local outputFilePath = os.getenv("LUAJIT_PROFILEFILE") -- Duplicated here just in case of upstream changes
	local scriptToProfile = table.remove(argv, 1)

	if not scriptToProfile then
		print(evo.messageStrings.PROFILE_COMMAND_USAGE_INFO)
		os.exit(EXIT_FAILURE)
	end

	if profilingModeFlags then
		printf("Detected LUAJIT_PROFILEMODE: %s", profilingModeFlags)
	end

	if outputFilePath then
		printf("Detected LUAJIT_PROFILEFILE: %s", outputFilePath)
	end

	profiler.start(profilingModeFlags, outputFilePath)
	evo.onInvalidCommand(scriptToProfile, argv)
	profiler.stop()
end

function evo.onInvalidCommand(command, argv)
	local isLuaScript = string.match(string.lower(command), ".*%.lua")
	if isLuaScript then
		return dofile(command)
	end

	local isStartCommand = (command == ".")
	if isStartCommand then
		return dofile(evo.DEFAULT_ENTRY_POINT)
	end

	if command ~= "" then
		printf(transform.brightRed("Invalid command: %s\n"), command)
	end

	evo.displayHelpText()
end

return evo
