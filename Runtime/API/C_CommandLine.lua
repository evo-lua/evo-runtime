local validation = require("validation")
local validateString = validation.validateString
local validateFunction = validation.validateFunction

local fallbackCommandHandler = function(command)
	if command == "" then
		print(C_CommandLine.GetUsageInfo())
		return
	end

	print("Not a valid command: " .. command)
	print()
	print()
end

local C_CommandLine = {
	PLACEHOLDER_COMMAND_DESCRIPTION = "No description available",
	FALLBACK_COMMAND_HANDLER = fallbackCommandHandler,
	registeredCommands = {},
	defaultCommandHandler = fallbackCommandHandler,
}

function C_CommandLine.RegisterCommand(commandName, commandHandler, description)
	validateString(commandName, "commandName")
	validateFunction(commandHandler, "commandHandler")
	if description ~= nil then
		validateString(description, "description")
	end

	if C_CommandLine.registeredCommands[commandName] then
		error(
			"Failed to register command '" .. commandName .. "' (a command handler already exists for this command)",
			0
		)
	end

	C_CommandLine.registeredCommands[commandName] = {
		handler = commandHandler,
		description = description or C_CommandLine.PLACEHOLDER_COMMAND_DESCRIPTION,
	}
end

function C_CommandLine.UnregisterCommand(commandName)
	validateString(commandName, "commandName")

	local isRegisteredCommand = C_CommandLine.registeredCommands[commandName]
	if not isRegisteredCommand then
		error("Failed to unregister command '" .. commandName .. "' (not a registered command)", 0)
	end

	C_CommandLine.registeredCommands[commandName] = nil
end

function C_CommandLine.GetCommandList()
	local commands = C_CommandLine.registeredCommands
	local commandList = {}
	for commandName, commandInfo in pairs(commands) do
		commandList[commandName] = commandInfo.description
	end
	return commandList
end

function C_CommandLine.GetUsageInfo()
	local usageInfoText = ""

	local commands = C_CommandLine.registeredCommands
	local sortedCommandNames = {}
	for commandName, commandInfo in pairs(commands) do
		table.insert(sortedCommandNames, commandName) -- Not yet sorted
	end

	table.sort(sortedCommandNames)

	for index, commandName in ipairs(sortedCommandNames) do
		local commandInfo = commands[commandName]
		usageInfoText = usageInfoText .. "\t" .. commandName .. "\t\t" .. commandInfo.description .. "\n"
	end

	return usageInfoText
end

function C_CommandLine.UnregisterAllCommands()
	C_CommandLine.registeredCommands = {}
end

function C_CommandLine.SetDefaultHandler(newDefaultHandler)
	validateFunction(newDefaultHandler, "newDefaultHandler")
	C_CommandLine.defaultCommandHandler = newDefaultHandler
end

function C_CommandLine.ProcessArguments(argumentsVector)
	validation.validateTable(argumentsVector, "argumentsVector")

	local command = argumentsVector[0] or ""

	for commandName, commandInfo in pairs(C_CommandLine.registeredCommands) do
		if command == commandName then
			return commandInfo.handler(command, argumentsVector)
		end
	end

	C_CommandLine.defaultCommandHandler(command)
end

return C_CommandLine
