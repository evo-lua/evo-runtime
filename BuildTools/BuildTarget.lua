local NinjaBuildTools = require("BuildTools.NinjaBuildTools")
local NinjaFile = require("BuildTools.NinjaFile")

local ffi = require("ffi")

local isWindows = (ffi.os == "Windows")
local isMacOS = (ffi.os == "OSX")
local isUnix = not (isWindows or isMacOS)

local BuildTarget = {}

function BuildTarget:Construct(instance)
	instance = instance or {}
	setmetatable(instance, self)
	self.__index = self
	return instance
end

function BuildTarget:GenerateNinjaFile()
	self.ninjaFile = NinjaFile()
	self.objectFiles = {}

	local GCC = NinjaBuildTools.GCC_COMPILATION_SETTINGS
	self:SetCompilerToolchain(GCC)
	self:SetLuaBytecodeGenerator()

	self:ComputeBuildEdges()

	return self.ninjaFile
end

function BuildTarget:SetCompilerToolchain(toolchainInfo)
	local ninjaFile = self.ninjaFile

	ninjaFile:AddVariable("C_COMPILER", toolchainInfo.C_COMPILER)
	ninjaFile:AddVariable("CPP_COMPILER", toolchainInfo.CPP_COMPILER)
	ninjaFile:AddVariable("COMPILER_FLAGS_C", toolchainInfo.COMPILER_FLAGS_C)
	ninjaFile:AddVariable("COMPILER_FLAGS_CPP", toolchainInfo.COMPILER_FLAGS_CPP)
	ninjaFile:AddVariable("C_LINKER", toolchainInfo.CPP_LINKER)
	ninjaFile:AddVariable("CPP_LINKER", toolchainInfo.CPP_LINKER)
	ninjaFile:AddVariable("LINKER_FLAGS", toolchainInfo.LINKER_FLAGS)
	ninjaFile:AddVariable("C_ARCHIVER", toolchainInfo.C_ARCHIVER)
	ninjaFile:AddVariable("CPP_ARCHIVER", toolchainInfo.CPP_ARCHIVER)
	ninjaFile:AddVariable("ARCHIVER_FLAGS", toolchainInfo.ARCHIVER_FLAGS)

	-- Technically, this is still specific to GCC due to the emitted deps file, but that could easily be changed later (if needed)
	ninjaFile:AddRule(
		"compile",
		"$CPP_COMPILER -c $in -o $out -MT $out -MMD -MF $out.d $COMPILER_FLAGS_CPP $includes $defines",
		{
			description = "Compiling $in ...",
			deps = "$C_COMPILER", --  g++ uses the same format as gcc
			depfile = "$out.d",
		}
	)
	ninjaFile:AddRule(
		"ccompile",
		"$C_COMPILER -c $in -o $out -MT $out -MMD -MF $out.d $COMPILER_FLAGS_C $includes $defines",
		{
			description = "Compiling $in ...",
			deps = "$C_COMPILER",
			depfile = "$out.d",
		}
	)
	ninjaFile:AddRule(
		"link",
		"$CPP_LINKER $in -o $out $libs $LINKER_FLAGS",
		{ description = "Linking target $out ..." }
	)
	ninjaFile:AddRule("clink", "$C_LINKER $in -o $out $libs $LINKER_FLAGS", { description = "Linking target $out ..." })

	self.toolchain = toolchainInfo
end

function BuildTarget:SetLuaBytecodeGenerator()
	-- Only LuaJIT is (and likely ever will be) supported
	local ninjaFile = self.ninjaFile

	local LUAJIT_EXECUTABLE_PATH = self.BUILD_DIR .. "/" .. NinjaBuildTools.GetExecutableName("luajit")
	ninjaFile:AddVariable("LUAJIT_EXECUTABLE", LUAJIT_EXECUTABLE_PATH)

	ninjaFile:AddRule(
		"bcsave",
		"$LUAJIT_EXECUTABLE -bg $in $out",
		{ description = "Saving LuaJIT bytecode for $in ..." }
	)

	self.bytecodeGenerator = LUAJIT_EXECUTABLE_PATH
end

function BuildTarget:ComputeBuildEdges()
	self:ProcessNativeSources()
	self:ProcessLuaSources()
	self:ProcessStaticLibraries()
end

function BuildTarget:ProcessNativeSources()
	local ninjaFile = self.ninjaFile
	local objectFiles = self.objectFiles

	-- On Linux, we need a lot of extra libraries, which could be anywhere
	-- The good news is that pkg-config should help discover them more or less reliably
	if isUnix then
		local webviewIncludeFlags = NinjaBuildTools.DiscoverIncludeDirectories("gtk+-3.0 webkit2gtk-4.0")
		for k, includeDir in ipairs(webviewIncludeFlags) do
			table.insert(self.includeDirectories, includeDir)
		end

		local webviewLibFlags = NinjaBuildTools.DiscoverSharedLibraries("gtk+-3.0 webkit2gtk-4.0")
		for _, libraryFlag in string.gmatch(webviewLibFlags, "-l(%w+)%s") do
			table.insert(self.sharedLibraries.Linux, libraryFlag)
		end
	end

	-- No point in fine-tuning include dirs since there's no duplicate headers anywhere, so just pass all of them every time
	local includes = ""
	for _, includeDir in ipairs(self.includeDirectories) do
		includes = includes .. "-I " .. includeDir .. " "
	end

	for index, cppSourceFilePath in ipairs(self.cppSources) do
		local outputFile =
			string.format("%s/%s.%s", self.BUILD_DIR, cppSourceFilePath, NinjaBuildTools.OBJECT_FILE_EXTENSION)

		-- Some dependencies demand special treatment because of how they use defines (questionably?)
		local defines = self:GetDefines()
		ninjaFile:AddBuildEdge(outputFile, "compile " .. cppSourceFilePath, { includes = includes, defines = defines })

		table.insert(objectFiles, outputFile)
	end

	for index, cSourceFilePath in ipairs(self.cSources) do
		local outputFile =
			string.format("%s/%s.%s", self.BUILD_DIR, cSourceFilePath, NinjaBuildTools.OBJECT_FILE_EXTENSION)

		-- Some dependencies demand special treatment because of how they use defines (questionably?)
		local defines = self:GetDefines()
		ninjaFile:AddBuildEdge(outputFile, "ccompile " .. cSourceFilePath, { includes = includes, defines = defines })

		table.insert(objectFiles, outputFile)
	end
end

function BuildTarget:GetDefines()
	local defines = string.format('-DEVO_VERSION=\\"%s\\"', self.GIT_VERSION_TAG)

	local discoveredLibraryVersions = require("deps.versions")

	local uwsVersionTag = discoveredLibraryVersions["deps/uNetworking/uWebSockets"].tag
	local uwsVersionString = string.match(uwsVersionTag, "(%d+.%d+.%d+)")
	defines = defines .. string.format(' -DUWS_VERSION=\\"%s\\"', uwsVersionString)
	defines = defines .. " -DUWS_HTTPRESPONSE_NO_WRITEMARK"

	local wgpuVersionTag = discoveredLibraryVersions["deps/gfx-rs/wgpu-native"].tag
	local wgpuVersionString = string.match(wgpuVersionTag, "(%d+.%d+.%d+)")
	defines = defines .. string.format(' -DWGPU_VERSION=\\"%s\\"', wgpuVersionString)

	local labsoundVersionTag = discoveredLibraryVersions["deps/LabSound/LabSound"].tag
	local labsoundVersionString = string.match(labsoundVersionTag, "(%d+.%d+.%d+)")
	defines = defines .. string.format(' -DLABSOUND_VERSION=\\"%s\\"', labsoundVersionString)

	local stduuidVersionTag = discoveredLibraryVersions["deps/mariusbancila/stduuid"].tag
	local stduuidVersionString = string.match(stduuidVersionTag, "(%d+.%d+.%d+)")
	defines = defines .. string.format(' -DSTDUUID_VERSION=\\"%s\\"', stduuidVersionString)

	return defines
end

function BuildTarget:ProcessLuaSources()
	local ninjaFile = self.ninjaFile
	local objectFiles = self.objectFiles

	for index, luaSourceFilePath in ipairs(self.luaSources) do
		local outputFile = string.format("%s/%s.%s", self.BUILD_DIR, luaSourceFilePath, "c")
		ninjaFile:AddBuildEdge(outputFile, "bcsave " .. luaSourceFilePath)
		table.insert(objectFiles, outputFile)
	end
end

function BuildTarget:ProcessStaticLibraries()
	local ninjaFile = self.ninjaFile
	local objectFiles = self.objectFiles

	-- Static libraries are linked in just like any other object, but at the very end (so that their symbols are resolved correctly)
	for index, libraryBaseName in ipairs(self.staticLibraries) do
		local relativeLibraryPath = self.BUILD_DIR .. "/" .. libraryBaseName
		table.insert(objectFiles, relativeLibraryPath)
	end

	local sharedLibraryFlags = ""
	for index, libraryBaseName in ipairs(self.sharedLibraries[ffi.os]) do
		local startsWithCapitalLetter = string.match(libraryBaseName, "^[A-Z]")
		local isAppleFramework = isMacOS and startsWithCapitalLetter
		local prefix = isAppleFramework and "-framework" or "-l"
		sharedLibraryFlags = sharedLibraryFlags .. " " .. prefix .. " " .. libraryBaseName
	end

	if isWindows and self.staticallyLinkStandardLibraries.Windows then
		sharedLibraryFlags = sharedLibraryFlags .. " " .. "-static-libgcc -static-libstdc++ -static -lpthread"
	end

	ninjaFile:AddBuildEdge(
		self.BUILD_DIR .. "/" .. self.OUTPUT_FILE_NAME,
		"link " .. table.concat(objectFiles, " "),
		{ libs = sharedLibraryFlags }
	)
end

function BuildTarget:ToString()
	return string.format(
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

BuildTarget.__call = BuildTarget.Construct
BuildTarget.__tostring = BuildTarget.ToString
setmetatable(BuildTarget, BuildTarget)

return BuildTarget
