local validation = require("validation")
local validateString = validation.validateString
local validateFunction = validation.validateFunction

local C_CommandLine = {
	PLACEHOLDER_COMMAND_DESCRIPTION = "No description available",
	registeredCommands = {},
	aliases = {},
}

function C_CommandLine.DispatchCommand(command)
	if command == "" then
		print(C_CommandLine.GetUsageInfo())
		return
	end

	print("Not a valid command: " .. command)
	print()
	print()
end

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
	C_CommandLine.aliases[commandName] = nil
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
		local alias = C_CommandLine.aliases[commandName]
		local commandText = alias and (alias .. "\t\t" .. format("%-8s", commandName) .. "") or commandName
		usageInfoText = usageInfoText .. "\t" .. commandText .. "\t" .. commandInfo.description .. "\n"
	end

	return usageInfoText
end

function C_CommandLine.UnregisterAllCommands()
	C_CommandLine.registeredCommands = {}
	C_CommandLine.aliases = {}
end

function C_CommandLine.SetDefaultHandler(newDefaultHandler)
	validateFunction(newDefaultHandler, "newDefaultHandler")
	C_CommandLine.DispatchCommand = newDefaultHandler
end

function C_CommandLine.ProcessArguments(argumentsVector)
	validation.validateTable(argumentsVector, "argumentsVector")

	local commandOrAlias = argumentsVector[0] or ""

	for commandName, commandInfo in pairs(C_CommandLine.registeredCommands) do
		if commandOrAlias == commandName then
			return commandInfo.handler(commandOrAlias, argumentsVector)
		end
	end

	for commandName, alias in pairs(C_CommandLine.aliases) do
		if commandOrAlias == alias then
			local commandInfo = C_CommandLine.registeredCommands[commandName]
			return commandInfo.handler(commandName, argumentsVector)
		end
	end

	C_CommandLine.DispatchCommand(commandOrAlias)
end

function C_CommandLine.SetAlias(commandName, alias)
	validateString(commandName, "commandName")
	validateString(alias, "alias")

	if not C_CommandLine.registeredCommands[commandName] then
		error(format("Cannot set alias %s for command %s (no such command was registered)", alias, commandName), 0)
	end

	local aliasedCommand
	for registeredCommand, registeredAlias in pairs(C_CommandLine.aliases) do
		if alias == registeredAlias then
			aliasedCommand = registeredCommand
		end
	end

	if aliasedCommand then
		error(
			format(
				"Cannot set alias %s for command %s (already used for command %s)",
				alias,
				commandName,
				aliasedCommand
			),
			0
		)
	end

	C_CommandLine.aliases[commandName] = alias
end

return C_CommandLine
