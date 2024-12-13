local git = {}

local currentSubmoduleName
local function parseNextLine(submodules, line)
	local submoduleName = line:match('%[submodule%s"(.*)%"]')
	if submoduleName then
		currentSubmoduleName = submoduleName
		submodules[submoduleName] = {}
		return
	end

	local recognizedFields = {
		-- Mandatory fields
		["path"] = tostring,
		["url"] = tostring,
		-- Optional fields
		["ignore"] = tostring,
		["update"] = tostring,
		["branch"] = tostring,
		["fetchRecurseSubmodules"] = tostring,
		["shallow"] = tostring,
	}

	for fieldName, _ in pairs(recognizedFields) do
		local matchedValue = line:match("%s?" .. fieldName .. "%s?=%s?(.*)")
		if matchedValue then
			submodules[currentSubmoduleName][fieldName] = matchedValue
			return
		end
	end
end

function git.modules(fileContents)
	fileContents = fileContents:gsub("\r\n", "\n")
	local lines = string.explode(fileContents, "\n")
	local submodules = {}

	for _, line in ipairs(lines) do
		parseNextLine(submodules, line)
	end

	return submodules
end

return git
