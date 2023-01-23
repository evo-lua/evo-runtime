-- CAUTION: This script MUST run as-is in stock LuaJIT, so that the runtime can be bootstrapped from source
-- That means you can only use standard LuaJIT functionality here, or the few dedicated modules designed to be portable
local ffi = require("ffi")
local isWindows = (ffi.os == "Windows")

local NinjaBuildTools = require("BuildTools.NinjaBuildTools")
local NinjaFile = require("BuildTools.NinjaFile")

local format = string.format
local GetExecutableName = NinjaBuildTools.GetExecutableName

local EvoBuildTarget = {
	OUTPUT_FILE_NAME = GetExecutableName("evo"),
	BUILD_DIR = NinjaBuildTools.DEFAULT_BUILD_DIRECTORY_NAME,
	GIT_VERSION_TAG = NinjaBuildTools.DiscoverGitVersionTag(),
	-- Can't easily discover sources or resolve paths with only Lua APIs. Listing them explicitly is probably safer anyway
	-- Note that ninja doesn't care about path separators and the mingw toolchain supports forward slashes; no \ required
	luaSources = {
		"deps/kikito/inspect.lua/inspect.lua",
		"Runtime/evo.lua",
		"Runtime/Extensions/debugx.lua",
		"Runtime/Extensions/stringx.lua",
		"Runtime/Libraries/assertions.lua",
		"Runtime/Libraries/bdd.lua",
		"Runtime/Libraries/transform.lua",
		"Runtime/Libraries/validation.lua",
	},
	cppSources = {
		"Runtime/main.cpp",
		"Runtime/evo.cpp",
		"Runtime/LuaVirtualMachine.cpp",
	},
	includeDirectories = {
		NinjaBuildTools.DEFAULT_BUILD_DIRECTORY_NAME, -- For auto-generated headers (e.g., PCRE2)
		"deps/LuaJIT/LuaJIT/src",
		"deps/luvit/luv/src",
		"deps/luvit/luv/deps/libuv/include",
	},
	staticLibraries = {
		"libluajit.a",
		"libluv.a",
		"libuv_a.a",
	},
	sharedLibraries = (
		isWindows and "-l PSAPI -l USER32 -l ADVAPI32 -l IPHLPAPI -l USERENV -l WS2_32 -l GDI32 -l CRYPT32"
		or "-lm -ldl -pthread"
	),
}

function EvoBuildTarget:GenerateNinjaFile()
	self.ninjaFile = NinjaFile()
	self.objectFiles = {}

	local GCC = NinjaBuildTools.GCC_COMPILATION_SETTINGS
	self:SetCompilerToolchain(GCC)
	self:SetLuaBytecodeGenerator()

	self:ComputeBuildEdges()

	return self.ninjaFile
end

function EvoBuildTarget:SetCompilerToolchain(toolchainInfo)
	local ninjaFile = self.ninjaFile

	ninjaFile:AddVariable("CPP_COMPILER", toolchainInfo.CPP_COMPILER)
	ninjaFile:AddVariable("COMPILER_FLAGS", toolchainInfo.COMPILER_FLAGS)
	ninjaFile:AddVariable("CPP_LINKER", toolchainInfo.CPP_LINKER)
	ninjaFile:AddVariable("LINKER_FLAGS", toolchainInfo.LINKER_FLAGS)
	ninjaFile:AddVariable("CPP_ARCHIVER", toolchainInfo.CPP_ARCHIVER)
	ninjaFile:AddVariable("ARCHIVER_FLAGS", toolchainInfo.ARCHIVER_FLAGS)

	-- Technically, this is still specific to GCC due to the emitted deps file, but that could easily be changed later (if needed)
	ninjaFile:AddRule(
		"compile",
		"$CPP_COMPILER -c $in -o $out -MT $out -MMD -MF $out.d $COMPILER_FLAGS $includes $defines",
		{
			description = "Compiling $in ...",
			deps = "$C_COMPILER", --  g++ uses the same format as gcc
			depfile = "$out.d",
		}
	)
	ninjaFile:AddRule(
		"link",
		"$CPP_LINKER $in -o $out $libs $LINKER_FLAGS",
		{ description = "Linking target $out ..." }
	)

	self.toolchain = toolchainInfo
end

function EvoBuildTarget:SetLuaBytecodeGenerator()
	-- Only LuaJIT is (and likely ever will be) supported
	local ninjaFile = self.ninjaFile

	local LUAJIT_EXECUTABLE_PATH = self.BUILD_DIR .. "/" .. GetExecutableName("luajit")
	ninjaFile:AddVariable("LUAJIT_EXECUTABLE", LUAJIT_EXECUTABLE_PATH)

	ninjaFile:AddRule(
		"bcsave",
		"$LUAJIT_EXECUTABLE -bg $in $out",
		{ description = "Saving LuaJIT bytecode for $in ..." }
	)

	self.bytecodeGenerator = LUAJIT_EXECUTABLE_PATH
end

function EvoBuildTarget:ComputeBuildEdges()
	self:ProcessNativeSources()
	self:ProcessLuaSources()
	self:ProcessStaticLibraries()
end

function EvoBuildTarget:ProcessNativeSources()
	local ninjaFile = self.ninjaFile
	local objectFiles = self.objectFiles

	-- No point in fine-tuning include dirs since there's no duplicate headers anywhere, so just pass all of them every time
	local includes = ""
	for _, includeDir in ipairs(self.includeDirectories) do
		includes = includes .. "-I " .. includeDir .. " "
	end

	for index, cppSourceFilePath in ipairs(self.cppSources) do
		local outputFile = format("%s/%s.%s", self.BUILD_DIR, cppSourceFilePath, NinjaBuildTools.OBJECT_FILE_EXTENSION)

		-- Some dependencies demand special treatment because of how they use defines (questionably?)
		local defines = self:GetDefines(cppSourceFilePath)
		ninjaFile:AddBuildEdge(outputFile, "compile " .. cppSourceFilePath, { includes = includes, defines = defines })

		table.insert(objectFiles, outputFile)
	end
end

function EvoBuildTarget:GetDefines(cppSourceFilePath)
	local defines = format('-DEVO_VERSION=\\"%s\\"', self.GIT_VERSION_TAG)

	local pcreDefines = "-DPCRE2_STATIC -DPCRE2_CODE_UNIT_WIDTH=8"
	defines = defines .. " " .. pcreDefines -- Since the runtime itself uses PCRE2 APIs to export the version, this is mandatory

	-- LREXLIB requires a VERSION define, which would be set by luarocks if we used that... but we don't, so discover it manually (hacky!)
	if string.match(cppSourceFilePath, "lrexlib") then
		local lrexlibVersionString = self.discoveredLrexlibVersion or self:DiscoverLrexlibVersion()
		self.discoveredLrexlibVersion = lrexlibVersionString -- Only do it once, not once per file...

		-- LREXLIB's overly generic VERSION define causes a conflict with LPEG (which does the same thing)
		defines = defines .. format(' -DVERSION=\\"%s\\"', lrexlibVersionString)
	end

	return defines
end

-- DEPRECATED: Obsoleted since lrexlib is no longer required?
function EvoBuildTarget:DiscoverLrexlibVersion()
	-- This is somewhat sketchy as it relies on many assumptions, but since lrexlib isn't really maintained that's probably OK-ish...
	-- The version is hardcoded in their Makefile and then propagated to the luarocks configuration
	local lrexlibMakefile = io.open("deps/lrexlib/Makefile", "r") -- Unix paths should be fine on MSYS
	local makefileContents = lrexlibMakefile:read("*a") -- It's not big, so no problem to keep it in memory here

	local expectedVersionPattern = "VERSION = (%d+.%d+.%d+)" -- Hopefully they will never change it :/
	local discoveredLrexlibVersion = string.match(makefileContents, expectedVersionPattern)

	lrexlibMakefile:close()

	return discoveredLrexlibVersion
end

function EvoBuildTarget:ProcessLuaSources()
	local ninjaFile = self.ninjaFile
	local objectFiles = self.objectFiles

	for index, luaSourceFilePath in ipairs(self.luaSources) do
		local outputFile = format("%s/%s.%s", self.BUILD_DIR, luaSourceFilePath, NinjaBuildTools.OBJECT_FILE_EXTENSION)
		ninjaFile:AddBuildEdge(outputFile, "bcsave " .. luaSourceFilePath)
		table.insert(objectFiles, outputFile)
	end
end

function EvoBuildTarget:ProcessStaticLibraries()
	local ninjaFile = self.ninjaFile
	local objectFiles = self.objectFiles

	-- Static libraries are linked in just like any other object, but at the very end (so that their symbols are resolved correctly)
	for index, libraryBaseName in ipairs(self.staticLibraries) do
		local relativeLibraryPath = self.BUILD_DIR .. "/" .. libraryBaseName
		table.insert(objectFiles, relativeLibraryPath)
	end

	ninjaFile:AddBuildEdge(
		self.BUILD_DIR .. "/" .. self.OUTPUT_FILE_NAME,
		"link " .. table.concat(objectFiles, " "),
		{ libs = self.sharedLibraries }
	)
end

function EvoBuildTarget:ToString()
	return format(
		[[

Target: %s
Version: %s
Build Directory: %s
Compiler Toolchain: %s
Bytecode Generator: %s
]],
		self.OUTPUT_FILE_NAME,
		self.GIT_VERSION_TAG,
		self.BUILD_DIR,
		self.toolchain.displayName,
		self.bytecodeGenerator
	)
end

print("Generating build configuration ...")
local ninjaFile = EvoBuildTarget:GenerateNinjaFile()

print(EvoBuildTarget:ToString())

print("Saving Ninja file: " .. NinjaFile.DEFAULT_BUILD_FILE_NAME)
ninjaFile:Save()
