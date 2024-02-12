local ipairs = ipairs
local table_concat = table.concat

local ffi = require("ffi")

local DEFAULT_REQUIRED_VERSION = "1.10.0" -- Whatever is available via apt (probably outdated)?
local DEFAULT_BUILD_DIRECTORY_NAME = "ninjabuild-" .. string.lower(ffi.os)
local DEFAULT_BUILD_FILE_NAME = "build.ninja"

local NinjaFile = {
	requiredVersion = DEFAULT_REQUIRED_VERSION,
	buildDirectory = DEFAULT_BUILD_DIRECTORY_NAME,
	includes = {},
}

NinjaFile.DEFAULT_REQUIRED_VERSION = DEFAULT_REQUIRED_VERSION
NinjaFile.DEFAULT_BUILD_FILE_NAME = "build.ninja"
NinjaFile.DEFAULT_BUILD_DIRECTORY_NAME = DEFAULT_BUILD_DIRECTORY_NAME
NinjaFile.AUTOGENERATION_HEADER_TEXT = "# AUTOMATICALLY GENERATED! Editing this file directly is not recommended."

function NinjaFile:Construct()
	local instance = {
		ruleDeclarations = {},
		buildEdges = {},
		variables = {},
	}

	instance.__index = self
	setmetatable(instance, instance)

	return instance
end

function NinjaFile:Save(filePath)
	filePath = filePath or DEFAULT_BUILD_FILE_NAME

	local fileContents = self:ToString()
	local file = io.open(filePath, "wb+")
	file:write(fileContents)
	file:close()
end

function NinjaFile:ToString()
	local fileContents = {}

	fileContents[#fileContents + 1] = NinjaFile.AUTOGENERATION_HEADER_TEXT
	fileContents[#fileContents + 1] = "ninja_required_version = " .. self.requiredVersion

	if #self.variables > 0 then
		fileContents[#fileContents + 1] = "\n# Variable declarations"
	end
	for index, variableName in ipairs(self.variables) do
		local declarationLine = self.variables[variableName]
		fileContents[#fileContents + 1] = variableName .. " = " .. declarationLine
	end

	if #self.ruleDeclarations > 0 then
		fileContents[#fileContents + 1] = "\n# Build rules"
	end
	for index, buildRule in ipairs(self.ruleDeclarations) do
		fileContents[#fileContents + 1] = "rule " .. buildRule.name
		fileContents[#fileContents + 1] = "  command = " .. buildRule.command

		if buildRule.description then
			fileContents[#fileContents + 1] = "  description = " .. buildRule.description
		end

		if buildRule.deps then
			fileContents[#fileContents + 1] = "  deps = " .. buildRule.deps
		end

		if buildRule.depfile then
			fileContents[#fileContents + 1] = "  depfile = " .. buildRule.depfile
		end

		if buildRule.generated then
			fileContents[#fileContents + 1] = "  generated = " .. buildRule.generated and "1" or "0"
		end
	end

	if #self.buildEdges > 0 then
		fileContents[#fileContents + 1] = "\n# Build edges"
	end

	for index, buildEdge in ipairs(self.buildEdges) do
		fileContents[#fileContents + 1] = "build " .. buildEdge.outputs .. ": " .. table_concat(buildEdge.inputs, " ")
		for name, value in pairs(buildEdge.variableOverrides) do
			fileContents[#fileContents + 1] = "  " .. name .. " = " .. value
		end
	end

	if #self.includes > 0 then
		fileContents[#fileContents + 1] = "\n# Includes"
	end
	for index, targetID in ipairs(self.includes) do
		fileContents[#fileContents + 1] = "subninja " .. targetID .. ".ninja"
	end

	return table_concat(fileContents, "\n") .. "\n"
end

function NinjaFile:AddVariable(name, value)
	self.variables[#self.variables + 1] = name
	self.variables[name] = value
end

function NinjaFile:AddRule(name, command, args)
	self.ruleDeclarations[#self.ruleDeclarations + 1] = {
		name = name,
		command = command,
		description = args.description,
		deps = args.deps,
		depfile = args.depfile,
		generated = args.generated,
	}
end

function NinjaFile:AddBuildEdge(outputs, input, variableOverrides)
	-- There can be multiple inputs, but this isn't the default
	local inputs = type(input) == "string" and { input } or input

	self.buildEdges[#self.buildEdges + 1] = {
		outputs = outputs,
		inputs = inputs,
		variableOverrides = variableOverrides or {},
	}
end

function NinjaFile:AddInclude(targetID)
	self.includes[#self.includes + 1] = targetID
end

NinjaFile.__call = NinjaFile.Construct
setmetatable(NinjaFile, NinjaFile)

return NinjaFile
