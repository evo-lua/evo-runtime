local transform = require("transform")

local bindingsDirectory = path.join("Runtime", "Bindings", "FFI")

local function discoverBindings(dir)
	local files = C_FileSystem.ReadDirectoryTree(dir)

	local luaModules = {}
	for fileSystemPath, isFIle in pairs(files) do
		local isLuaModule = path.extname(fileSystemPath) == ".lua"
		if isLuaModule then
			table.insert(luaModules, path.basename(fileSystemPath, ".lua"))
		end
	end

	return luaModules
end

local function string_explode_with_newlines(fileContents)
	-- string.explode skips empty lines and so cannot be used here
	local lines = {}
	for line in string.gmatch(fileContents, "([^\n]*)\n?") do
		table.insert(lines, line)
	end
	return lines
end

local function updateTypeDefinitions(binding)
	local fileSystemPath = path.join(bindingsDirectory, binding, binding .. ".lua")
	printf("Updating cdefs for %s (package name: %s)", transform.green(fileSystemPath), transform.blue(binding))
	local moduleFileContents = C_FileSystem.ReadFile(fileSystemPath)

	local lines = string_explode_with_newlines(moduleFileContents)
	local cdefsStart, cdefsEnd
	printf("Processed %d lines ", #lines)
	for lineNumber, line in ipairs(lines) do
		if line:find(format("^%s.cdefs =", binding)) then
			printf("Found cdefs starting at line %d: %s", lineNumber, line)
			cdefsStart = lineNumber
		end

		if cdefsStart and line:find("^]]$") then
			printf("Found cdefs ending at line %d: %s", lineNumber, line)
			cdefsEnd = lineNumber
		end
	end

	printf(
		"Replacing the cdefs found between lines %d and %d (%d lines)",
		cdefsStart,
		cdefsEnd,
		cdefsEnd - cdefsStart - 2
	)

	local aliasedDefinitionsPath = path.join(bindingsDirectory, binding, binding .. "_aliases.h")
	local hasAliases = C_FileSystem.Exists(aliasedDefinitionsPath)
	local exportDefinitionsPath = path.join(bindingsDirectory, binding, binding .. "_exports.h")

	local updatedAliases = hasAliases and C_FileSystem.ReadFile(aliasedDefinitionsPath) or ""
	local updatedDefinitions = C_FileSystem.ReadFile(exportDefinitionsPath)
	local cdefLines = string_explode_with_newlines(updatedAliases .. "\n" .. updatedDefinitions)
	printf(
		"Updating with cdefs found in %s and %s (%d lines)",
		exportDefinitionsPath,
		aliasedDefinitionsPath,
		#cdefLines
	)

	local updatedLines = {}
	for lineNumber = 1, cdefsStart, 1 do
		table.insert(updatedLines, lines[lineNumber])
	end

	for index, line in ipairs(cdefLines) do
		table.insert(updatedLines, line)
	end

	for lineNumber = cdefsEnd, #lines, 1 do
		table.insert(updatedLines, lines[lineNumber])
	end

	printf("Updated bindings will have %d lines (was %d before the update)", #updatedLines, #lines)
	local updatedFileContents = table.concat(updatedLines, "\n")
	printf(
		"Writing updated bindings to %s (new file size: %d bytes, previously: %d bytes)",
		fileSystemPath,
		#updatedFileContents,
		#moduleFileContents
	)

	C_FileSystem.WriteFile(fileSystemPath, updatedFileContents)
end

local bindings = discoverBindings(bindingsDirectory)
table.sort(bindings)

printf("Discovered %d bindings in %s:", #bindings, bindingsDirectory)
dump(bindings)

for index, binding in ipairs(bindings) do
	printf("Synchronizing FFI type definitions for binding %s", transform.blue(binding))
	updateTypeDefinitions(binding)
	printf("Synchronized FFI type definitions for binding %s\n", transform.blue(binding))
end
