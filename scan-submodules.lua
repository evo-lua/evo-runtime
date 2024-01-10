local ENABLE_DEBUG_MODE = false

local format = string.format
local print = print
local printf = printf
local tonumber = tonumber

local string_match = string.match
local table_concat = table.concat
local table_insert = table.insert

local transform = require("transform")
local bold = transform.bold
local cyan = transform.cyan
local green = transform.green
local red = transform.red
local yellow = transform.yellow

local nonstandardBranches = {
	["deps/LuaJIT/LuaJIT"] = "v2.1",
	["deps/gfx-rs/wgpu-native"] = "trunk",
	["deps/LabSound/LabSound"] = "main",
}

local function shell_exec(cmd)
	local file = assert(io.popen(cmd, "r"))
	local output = file:read("*all")
	file:close()

	if ENABLE_DEBUG_MODE then
		print("[SHELL] " .. green(cmd) .. " -> " .. cyan(output))
	end

	return output
end

local SubmoduleUpdateChecker = {
	exitCode = 0,
	summarySuccess = {},
	summaryFailure = {},
}

-- Get the hash of the latest commit that is tagged in the upstream repository
function SubmoduleUpdateChecker:GetLatestTagForSubmodule(path)
	local latestCommitWithATag = shell_exec(format("git -C %s rev-list --tags --max-count=1", path)):gsub("%s+$", "")
	local associatedTag = shell_exec(format("git -C %s describe --tags %s", path, latestCommitWithATag)):gsub("\n$", "")
	return associatedTag
end

function SubmoduleUpdateChecker:GetNewCommitInfo(path, branch)
	shell_exec(format("git -C %s fetch origin %s", path, branch))

	local localCommit = shell_exec(format("git -C %s rev-parse HEAD", path))
	local remoteCommit = shell_exec(format("git -C %s rev-parse origin/%s", path, branch))

	local hasUpstreamTags = (shell_exec(format("git -C %s tag -l", path)) ~= "")
	local tagLine = "~ no tags found"

	if hasUpstreamTags then
		local latestUpstreamTag = self:GetLatestTagForSubmodule(path)
		local latestCheckedOutTag = shell_exec(format("git -C %s describe --tags", path)):gsub("\n$", "")
		tagLine = "~ latest tagged release: " .. latestUpstreamTag .. " (checked out: " .. latestCheckedOutTag .. ")"
	end

	local hasRemoteNewCommits = (localCommit ~= remoteCommit)
	if hasRemoteNewCommits then
		local numCommits = tonumber(shell_exec(format("git -C %s rev-list --count HEAD..origin/%s", path, branch)))
		printf(bold(format("\nThere are %d new commit(s) in %s:\n", numCommits, path)))
		local command = format(
			'git -C %s --no-pager log --format="%%ai %%h %%s" --abbrev-commit --max-count=5 HEAD..origin/%s',
			path,
			branch
		)
		local new_commits = shell_exec(command)
		print(
			yellow(new_commits)
				.. (
					(numCommits > 5)
						and "... and " .. (numCommits - 5) .. " additional commits (omitted for brevity)\n"
					or ""
				)
		)
		table_insert(
			self.summaryFailure,
			red("✗ " .. path .. ": " .. numCommits .. " new commit(s) on origin/" .. branch .. " " .. tagLine)
		)
		self.exitCode = 1
	else
		print(cyan("\nSubmodule " .. path .. " is up-to-date.\n"))
		table_insert(
			self.summarySuccess,
			green("✓ " .. path .. ": No new commits on branch " .. branch .. " " .. tagLine)
		)
	end
end

function SubmoduleUpdateChecker:GetUpdatedSubmoduleStatus()
	local status = shell_exec("git submodule status")
	local lines = string.explode(status, "\n")

	for _, line in ipairs(lines) do
		local checkedOutCommitHash, submodulePath, checkedOutVersionTag =
			string_match(line, "%s?[%+%-U]?([0-9a-z]+).*(deps/%S+).*%((.*)%)")

		local branch = nonstandardBranches[submodulePath] or "master"
		printf("Fetching changes from %s for submodule %s ...", bold("origin/" .. branch), bold(submodulePath))
		printf("Checked out at commit %s (tagged as %s)\n", bold(checkedOutVersionTag), bold(checkedOutCommitHash))

		self:GetNewCommitInfo(submodulePath, branch)
	end
end

function SubmoduleUpdateChecker:PrintSummary()
	print(bold("Summary:\n"))
	print(table_concat(self.summarySuccess, "\n"))
	if #self.summaryFailure > 0 then
		print(table_concat(self.summaryFailure, "\n"))
		os.exit(self.exitCode)
	end
end

SubmoduleUpdateChecker:GetUpdatedSubmoduleStatus()
SubmoduleUpdateChecker:PrintSummary()
