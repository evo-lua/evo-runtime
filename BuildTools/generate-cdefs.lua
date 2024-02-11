local format = string.format
local function printf(...)
	print(format(...))
end

local buildDirectory = require("BuildTools.Targets.EvoBuildTarget").BUILD_DIR
printf("Selected BUILD_DIR: %s", buildDirectory)

local function exportTypeDefinitions(inputFilePath, outputFilePath)
	local inputFile, err = io.open(inputFilePath, "r")
	if not inputFile then
		io.stderr:write("Error opening input file: " .. err .. "\n")
		os.exit(1)
	end

	local fileContents = inputFile:read("*a")
	inputFile:close()

	local output = format(
		[[
-- This file was automatically generated. Editing it is pointless.
return %s
%s
%s
]],
		"[[",
		fileContents,
		"]]"
	)

	-- Write the output file
	local outputFile, errorMessage = io.open(outputFilePath, "w")
	if not outputFile then
		io.stderr:write("Error opening output file: " .. errorMessage .. "\n")
		os.exit(1)
	end

	outputFile:write(output)
	outputFile:close()
end

local BINDINGS_DIR = "Runtime/Bindings/"
local inputFiles = {
	"crypto_exports.h",
	"glfw_aliases.h",
	"glfw_exports.h",
	"iconv_exports.h",
	"interop_aliases.h",
	"interop_exports.h",
	"labsound_aliases.h",
	"labsound_exports.h",
	"rml_aliases.h",
	"rml_exports.h",
	"runtime_exports.h",
	"rml_exports.h",
	"stbi_exports.h",
	"stduuid_exports.h",
	"uws_aliases.h",
	"uws_exports.h",
	"webgpu_aliases.h",
	"webgpu_exports.h",
	"webview_aliases.h",
	"webview_exports.h",
}

for index, inputFile in ipairs(inputFiles) do
	local inputFilePath = BINDINGS_DIR .. inputFile
	local outputFilePath = buildDirectory .. "/" .. inputFile .. ".lua"
	outputFilePath = outputFilePath:gsub("%.h%.lua", ".lua")
	printf("Exporting type definitions: %s -> %s", inputFilePath, outputFilePath)
	exportTypeDefinitions(inputFilePath, outputFilePath)
end

printf("Generating merged cdefs module for %s input files", #inputFiles)

local cdefs = {}

for index, inputFile in ipairs(inputFiles) do
	local moduleName = inputFile:gsub("%.h", "")
	local modulePath = buildDirectory .. "." .. moduleName
	local returnedTypeDefs = require(modulePath)
	local libraryName = moduleName:gsub("_(.*)", "")
	printf("Processed %s: Read %s bytes for cdefs.%s", inputFile, #returnedTypeDefs, libraryName)
	cdefs[libraryName] = cdefs[libraryName] or {}
	table.insert(cdefs[libraryName], returnedTypeDefs)
end

local exportFile = io.open("deps/cdefs.lua", "w+")
exportFile:write("return {\n")
for libraryName, typeDefinitions in pairs(cdefs) do
	exportFile:write("\t" .. libraryName .. " = {\n")
	printf("Exporting %s cdef entries for namespace %s", #typeDefinitions, libraryName)
	for index, cdefString in ipairs(typeDefinitions) do
		exportFile:write("[[\n", cdefString .. "\n]],\n")
	end
	exportFile:write("\t},\n")
end
exportFile:write("}")

exportFile:close()
