local ENABLE_DEBUG_MODE = true

local format = string.format
local print = print
local printf = printf

local git = require("git")
local path = require("path")
local transform = require("transform")
local cyan = transform.cyan
local green = transform.green

local function table_keys(t)
	local keys = {}
	for k, _ in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

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

local submoduleID = arg[1]
if not submoduleID then
	print("Please specify a submodule to update")
	os.exit(1)
end

local gitmodulesFileContents = C_FileSystem.ReadFile(".gitmodules")
local submodules = git.modules(gitmodulesFileContents)
local submoduleToUpdate = submodules[submoduleID] or submodules[submoduleID:lower()]
if not submoduleToUpdate then
	printf("Cannot upgrade submodule (invalid submodule ID: %s)", submoduleID)
	printf("Valid submodule IDs are: %s", table.concat(table_keys(submodules), ", "))
	os.exit(1)
end

SubmoduleUpdater:ResetSubmoduleState(submoduleToUpdate)
SubmoduleUpdater:FetchLatestChangesForSubmodule(submoduleToUpdate)
SubmoduleUpdater:CommitLatestChangesForSubmodule(submoduleToUpdate)
