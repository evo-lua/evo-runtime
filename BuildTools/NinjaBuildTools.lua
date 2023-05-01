local ffi = require("ffi")

local isWindows = (ffi.os == "Windows")

local C_BuildTools = {
	OBJECT_FILE_EXTENSION = (isWindows and "obj" or "o"),
	STATIC_LIBRARY_EXTENSION = (isWindows and ".lib" or ".a"),
	SHARED_LIBRARY_EXTENSION = (isWindows and ".dll" or ".so"),
	EXECUTABLE_FILE_EXTENSION = (isWindows and ".exe" or ""),
	DEFAULT_BUILD_DIRECTORY_NAME = "ninjabuild-" .. (isWindows and "windows" or "unix"),
	GCC_COMPILATION_SETTINGS = {
		displayName = "GNU Compiler Collection",
		CPP_COMPILER = "g++",
		COMPILER_FLAGS = "-O2 -DNDEBUG -g -std=c++20 -Wall -Wextra -Wno-missing-field-initializers -Wno-unused-parameter -fvisibility=hidden -fno-strict-aliasing -fdiagnostics-color",
		CPP_LINKER = "g++",
		-- Must export the entry point of bytecode objects so that LuaJIT can load them via require()
		LINKER_FLAGS = isWindows and "-Wl,--export-all-symbols" or "-rdynamic",
		CPP_ARCHIVER = "ar",
		ARCHIVER_FLAGS = "-rcs",
	},
	SEMANTIC_VERSION_STRING_PATTERN = "(v(%d+)%.(%d+)%.(%d+).*)", --vMAJOR.MINOR.PATCH-optionalGitDescribeSuffix
	GITHUB_REPOSITORY_URL = "https://github.com/evo-lua/evo-runtime",
	CHANGELOG_FILE_PATH = "CHANGELOG.MD",
	PROJECT_AUTHORS = {
		-- This is only useful to exclude myself from the auto-generated changelog. No one cares otherwise - it's the work that matters ;)
		"Duckwhale", -- The humble author's GitHub name
		"RDW", -- The humble author's Discord name (stored in my local git config)
	},
}

function C_BuildTools.GetStaticLibraryName(libraryBaseName)
	return (isWindows and "" or "lib") .. libraryBaseName .. C_BuildTools.STATIC_LIBRARY_EXTENSION
end

function C_BuildTools.GetSharedLibraryName(libraryBaseName)
	return (isWindows and "" or "lib") .. libraryBaseName .. C_BuildTools.SHARED_LIBRARY_EXTENSION
end

function C_BuildTools.GetExecutableName(libraryBaseName)
	return libraryBaseName .. C_BuildTools.EXECUTABLE_FILE_EXTENSION
end

function C_BuildTools.GetOutputFromShellCommand(shellCommand)
	local file = assert(io.popen(shellCommand, "r"))

	file:flush() -- Required to prevent receiving only partial output
	local output = file:read("*all")
	file:close()

	return output
end

local function explode(inputString, delimiter)
	delimiter = delimiter or "%s"

	local tokens = {}
	for token in string.gmatch(inputString, "([^" .. delimiter .. "]+)") do
		table.insert(tokens, token)
	end
	return tokens
end

function C_BuildTools.DiscoverSharedLibraries(packageNames)
	local pkgConfigCommand = "pkg-config --libs-only-l " .. packageNames
	local output = C_BuildTools.GetOutputFromShellCommand(pkgConfigCommand)

	return output
end

function C_BuildTools.DiscoverIncludeDirectories(packageNames)
	local pkgConfigCommand = "pkg-config --cflags-only-I " .. packageNames .. ' | tr " " "\n" | sed \'s/^-I//\''
	local output = C_BuildTools.GetOutputFromShellCommand(pkgConfigCommand)

	return explode(output, "\n")
end

function C_BuildTools.DiscoverPreviousGitVersionTag()
	-- Need to exclude non-versioned tags, but git tag can't do the filtering by itself...
	local gitDescribeCommand = 'git describe --tags --abbrev=0 --match "v[0-9]*.[0-9]*.[0-9]*" HEAD~1'
	local versionTag = C_BuildTools.GetOutputFromShellCommand(gitDescribeCommand)

	-- Strip final newline since that's not very useful outside of the shell
	versionTag = string.sub(versionTag, 0, string.len(versionTag) - 1)

	return versionTag
end

function C_BuildTools.DiscoverGitVersionTag()
	-- Need to exclude non-versioned tags
	local gitDescribeCommand = "git describe --tags --match='v[0-9]*.[0-9]*.[0-9]*'"
	local versionTag = C_BuildTools.GetOutputFromShellCommand(gitDescribeCommand)

	-- Strip final newline since that's not very useful outside of the shell
	versionTag = string.sub(versionTag, 0, string.len(versionTag) - 1)

	return versionTag
end

function C_BuildTools.DiscoverMergeCommitsBetween(oldVersion, newVersion)
	if oldVersion == newVersion then
		return {}
	end

	-- This is the format string used by NodeJS changelogs, but modified to display shorter hashes
	local gitDescribeCommand = "git log "
		.. oldVersion
		.. "..."
		.. newVersion
		.. " --merges --pretty='format:* \\[[`%h`]("
		.. C_BuildTools.GITHUB_REPOSITORY_URL
		.. "/commit/%H)] - %b'"

	local commits = C_BuildTools.GetOutputFromShellCommand(gitDescribeCommand)
	commits = string.explode(commits, "\n") -- By default, Git outputs one commit per line

	return commits
end

function C_BuildTools.DiscoverCommitAuthorsBetween(oldVersion, newVersion)
	local gitLogCommand = 'git log --pretty=format:"%an" ' .. oldVersion .. ".." .. newVersion .. " | sort | uniq"

	local committers = C_BuildTools.GetOutputFromShellCommand(gitLogCommand)
	committers = string.explode(committers, "\n") -- By default, git log outputs one entry per line

	return committers
end

-- This would be cleaner if we kept the PROJECT_AUTHORS as an array, but then we'd still need to iterate and check the values...
local function convertArrayToSet(arrayTable)
	local setTable = {}

	for index, value in ipairs(arrayTable) do
		setTable[value] = true
	end

	return setTable
end

function C_BuildTools.DiscoverExternalContributorsBetween(oldVersion, newVersion)
	local committers = C_BuildTools.DiscoverCommitAuthorsBetween(oldVersion, newVersion)

	local externalContributors = {}

	for index, authorName in ipairs(committers) do -- Conveniently already sorted alphabetically if we use ipairs after piping to sort
		local isProjectAuthor = convertArrayToSet(C_BuildTools.PROJECT_AUTHORS)[authorName]
		-- The changelog should list all external contributors, to show appreciation for their work
		-- No point in self-aggrandizing by adding the project authors (i.e., myself) to every change log...
		if not isProjectAuthor then
			externalContributors[#externalContributors + 1] = authorName
		end
	end

	return externalContributors
end

function C_BuildTools.GetChangelogEntry(oldVersion, newVersion)
	local notableChanges = C_BuildTools.FetchNotableChanges(newVersion)

	if not notableChanges then
		return {}
	end

	local changelogEntry = {
		versionTag = newVersion,
		newFeatures = notableChanges.newFeatures or {},
		improvements = notableChanges.improvements or {},
		breakingChanges = notableChanges.breakingChanges or {},
		pullRequests = C_BuildTools.DiscoverMergeCommitsBetween(oldVersion, newVersion) or {},
		contributors = notableChanges.contributors
			or C_BuildTools.DiscoverExternalContributorsBetween(oldVersion, newVersion),
	}

	return changelogEntry
end

function C_BuildTools.FetchNotableChanges(versionTag)
	-- Defer loading since this isn't generally useful and might take up more space eventually
	local notableChanges = require("changelog")
	return notableChanges[versionTag] or {}
end

local format = _G.format or string.format -- Can be removed after the format alias has been re-introduced

-- This is screaming to get out and become its own class, but for the time being it shall remain imprisoned...
local function markdownFile_AddCategory(markdownFile, category)
	if #category.entries == 0 then
		-- We don't want to list empty categories now, do we?
		return markdownFile
	end

	markdownFile = markdownFile .. format("### %s\n\n", category.name)

	for k, v in ipairs(category.entries) do
		markdownFile = markdownFile .. "* " .. v .. "\n"
	end

	markdownFile = markdownFile .. "\n"

	return markdownFile
end

function C_BuildTools.StringifyChangelogContents(changelogEntry)
	local markdownFile = "# " .. changelogEntry.versionTag .. "\n\n"

	local changelogCategories = {
		-- The order that categories appear in is important, so this has to be an array (even if it's more verbose)
		{
			name = "New Features",
			entries = changelogEntry.newFeatures,
		},
		{
			name = "Improvements",
			entries = changelogEntry.improvements,
		},
		{
			name = "Breaking Changes",
			entries = changelogEntry.breakingChanges,
		},
	}

	for index, category in ipairs(changelogCategories) do
		markdownFile = markdownFile_AddCategory(markdownFile, category)
	end

	-- The format for pull requests is derived from git console output, so let's not touch that (fow now)
	markdownFile = markdownFile .. "### Pull Requests\n\n" .. table.concat(changelogEntry.pullRequests, "\n") .. "\n\n"

	markdownFile = markdownFile .. "#### Contributors (in alphabetical order)\n\n"

	if #changelogEntry.contributors == 0 then
		markdownFile = markdownFile .. "* No external contributors"
	end

	-- This is also somewhat messy due to the PRs needing to be displayed first - for now it'll have to do though
	local contributors = { name = "Contributors (in alphabetical order)", entries = changelogEntry.contributors }
	markdownFile = markdownFile_AddCategory(markdownFile, contributors)

	return markdownFile
end

function C_BuildTools.GenerateChangeLog(from, to)
	local transform = require("transform")

	local currentVersionTag = C_BuildTools.DiscoverGitVersionTag()
	local previousVersionTag = C_BuildTools.DiscoverPreviousGitVersionTag()

	previousVersionTag = from or previousVersionTag
	currentVersionTag = to or currentVersionTag

	print("Generating changelog for release " .. transform.green(currentVersionTag))
	print(
		"Including changes from " .. transform.green(previousVersionTag) .. " to " .. transform.green(currentVersionTag)
	)

	local changes = C_BuildTools.GetChangelogEntry(previousVersionTag, currentVersionTag)
	local markdownChanges = C_BuildTools.StringifyChangelogContents(changes)

	print("Changelog summary:")

	local numPullRequests = #changes.pullRequests
	if numPullRequests == 0 then
		numPullRequests = "NO"
	end
	local numFeatures = #changes.newFeatures
	if numFeatures == 0 then
		numFeatures = "NO"
	end
	local numImprovements = #changes.improvements
	if numImprovements == 0 then
		numImprovements = "NO"
	end
	local numBreakingChanges = #changes.breakingChanges
	if numBreakingChanges == 0 then
		numBreakingChanges = "NO"
	end
	local numContributors = #changes.contributors
	if numContributors == 0 then
		numContributors = "NO"
	end

	printf("* %s new feature%s", numFeatures, numFeatures == 1 and "" or "s")
	printf("* %s improvement%s", numImprovements, numImprovements == 1 and "" or "s")
	printf("* %s breaking change%s", numBreakingChanges, numBreakingChanges == 1 and "" or "s")
	printf("* %s pull request%s", numPullRequests, numPullRequests == 1 and "" or "s")
	printf("* %s external contributor%s", numContributors, numContributors == 1 and "" or "s")
	print("Saving changelog as " .. transform.green(C_BuildTools.CHANGELOG_FILE_PATH))

	C_FileSystem.WriteFile(C_BuildTools.CHANGELOG_FILE_PATH, markdownChanges)
end

return C_BuildTools
