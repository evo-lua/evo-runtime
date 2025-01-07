local ENABLE_DEBUG_MODE = true

local format = string.format
local print = print
local printf = printf

local git = require("git")
local path = require("path")
local transform = require("transform")
local cyan = transform.cyan
local green = transform.green
local red = transform.red

local function shell_exec(cmd)
	local file = assert(io.popen(cmd, "r"))
	local output = file:read("*all")
	file:close()

	if ENABLE_DEBUG_MODE then
		printf("[SHELL] %s -> %s", green(cmd), cyan(output))
	end

	return output
end

local SubmoduleUpdater = {}

function SubmoduleUpdater:RecurseAndResetSubmodules()
	print("Recursively resetting all submodules to get rid of any local changes")
	shell_exec("git submodule foreach --recursive 'git clean -fd'")
	shell_exec("git submodule foreach --recursive 'git reset --hard HEAD'")
	shell_exec("git submodule foreach --recursive 'git restore .'")
end

function SubmoduleUpdater:ResetSubmoduleState(submodule)
	local commands = {}

	print("Resetting submodule " .. submodule.path)
	table.insert(commands, "cd " .. submodule.path)
	table.insert(commands, "git clean -fd")
	table.insert(commands, format("git checkout %s", submodule.branch))
	table.insert(commands, format("git reset --hard %s", submodule.branch))
	table.insert(commands, "git restore .")
	table.insert(commands, format("git submodule update --init --recursive"))

	local command = table.concat(commands, " && ")
	shell_exec(command)
end

function SubmoduleUpdater:FetchLatestChangesForSubmodule(submodule)
	local commands = {}

	print("Fetching changes for submodule " .. submodule.path)
	table.insert(commands, "cd " .. submodule.path)
	table.insert(commands, "git fetch origin")
	table.insert(commands, "git pull --rebase")

	local command = table.concat(commands, " && ")
	shell_exec(command)
end

function SubmoduleUpdater:CommitLatestChangesForSubmodule(submodule)
	local commands = {}

	local displayName = path.basename(submodule.path)
	local standardizedUpdateBranchName = string.lower(format("%s-update-latest", displayName:lower()))
	local standardizedUpdateCommitMessage = format('"Deps: Update %s to the latest HEAD"', displayName)

	printf("Committing changes for submodule %s to branch %s", displayName, standardizedUpdateBranchName)
	table.insert(commands, "git checkout main")
	table.insert(commands, format("git update-ref -d refs/heads/%s", standardizedUpdateBranchName))
	table.insert(commands, format("git checkout -b %s", standardizedUpdateBranchName))
	table.insert(commands, format("git add %s", submodule.path))
	table.insert(commands, format("git commit -m %s", standardizedUpdateCommitMessage))

	local command = table.concat(commands, " && ")
	shell_exec(command)
end

function SubmoduleUpdater:GetHelpText(submodules)
	local sortedKeys = table.keys(submodules)
	table.sort(sortedKeys)

	local indent = "  "
	local readableList = indent .. table.concat(sortedKeys, "\n" .. indent)

	return "Valid submodule IDs:\n\n" .. readableList
end

local gitmodulesFileContents = C_FileSystem.ReadFile(".gitmodules")
local submodules = git.modules(gitmodulesFileContents)

local submoduleID = arg[1]
if not submoduleID then
	print(red("Please specify a submodule to update!\n"))
	print(SubmoduleUpdater:GetHelpText(submodules))
	os.exit(1)
end

local submoduleToUpdate = submodules[submoduleID]
if not submoduleToUpdate then
	printf(red("Cannot upgrade submodule %s (invalid submodule ID)\n"), submoduleID)
	print(SubmoduleUpdater:GetHelpText(submodules))
	os.exit(1)
end

SubmoduleUpdater:ResetSubmoduleState(submoduleToUpdate)
SubmoduleUpdater:FetchLatestChangesForSubmodule(submoduleToUpdate)
SubmoduleUpdater:CommitLatestChangesForSubmodule(submoduleToUpdate)
