local ENABLE_DEBUG_MODE = true

local format = string.format
local print = print
local printf = printf

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

local submodules = {
	luajit = {
		path = "deps/LuaJIT/LuaJIT",
		branch = "v2.1",
		abbreviatedName = "luajit",
		displayName = "LuaJIT",
	},
	openssl = {
		path = "deps/openssl/openssl",
		branch = "master",
		abbreviatedName = "openssl",
		displayName = "OpenSSL",
	},
	pcre = {
		path = "deps/PCRE2Project/pcre2",
		branch = "master",
		abbreviatedName = "pcre2",
		displayName = "PCRE2",
	},
	glfw = {
		path = "deps/glfw/glfw",
		branch = "master",
		abbreviatedName = "glfw",
		displayName = "GLFW",
	},
	luv = {
		path = "deps/luvit/luv",
		branch = "master",
		abbreviatedName = "luv",
		displayName = "luv",
	},
	webview = {
		path = "deps/webview/webview",
		branch = "master",
		abbreviatedName = "webview",
		displayName = "webview",
	},
	["lua-openssl"] = {
		path = "deps/zhaog/lua-openssl",
		branch = "master",
		abbreviatedName = "luaossl",
		displayName = "lua-openssl",
	},
	uws = {
		path = "deps/uNetworking/uWebSockets",
		branch = "master",
		abbreviatedName = "uws",
		displayName = "uWebSockets",
	},
	wgpu = {
		path = "deps/gfx-rs/wgpu-native",
		branch = "trunk",
		abbreviatedName = "wgpu",
		displayName = "wgpu-native",
	},
	lzlib = {
		path = "deps/brimworks/lua-zlib",
		branch = "master",
		abbreviatedName = "lzlib",
		displayName = "lua-zlib",
	},
	zlib = {
		path = "deps/madler/zlib",
		branch = "master",
		abbreviatedName = "zlib",
		displayName = "zlib",
	},
	lrexlib = {
		path = "deps/rrthomas/lrexlib",
		branch = "master",
		abbreviatedName = "lrexlib",
		displayName = "lrexlib",
	},
	["lua-rapidjson"] = {
		path = "deps/xpol/lua-rapidjson",
		branch = "master",
		abbreviatedName = "lrjson",
		displayName = "lua-rapidjson",
	},
	["lua-utf8"] = {
		path = "deps/starwing/luautf8",
		branch = "master",
		abbreviatedName = "lutf8",
		displayName = "lua-utf8",
	},
	stb = {
		path = "deps/nothings/stb",
		branch = "master",
		abbreviatedName = "stb",
		displayName = "stb",
	},
	stduuid = {
		path = "deps/mariusbancila/stduuid",
		branch = "master",
		abbreviatedName = "uuid",
		displayName = "stduuid",
	},
	miniz = {
		path = "deps/richgel999/miniz",
		branch = "master",
		abbreviatedName = "miniz",
		displayName = "miniz",
	},
	inspect = {
		path = "deps/kikito/inspect.lua",
		branch = "master",
		abbreviatedName = "inspect",
		displayName = "inspect.lua",
	},
	lpeg = {
		path = "deps/roberto-ieru/LPeg",
		branch = "master",
		abbreviatedName = "lpeg",
		displayName = "LPEG",
	},
	rml = {
		path = "deps/mikke89/RmlUi",
		branch = "master",
		abbreviatedName = "rml",
		displayName = "RML",
	},
	freetype = {
		path = "deps/freetype/freetype",
		branch = "master",
		abbreviatedName = "freetype",
		displayName = "FreeType",
	},
	labsound = {
		path = "deps/LabSound/LabSound",
		branch = "main",
		abbreviatedName = "labsound",
		displayName = "LabSound",
	},
	rapidjson = {
		path = "deps/Tencent/rapidjson",
		branch = "master",
		abbreviatedName = "rjson",
		displayName = "rapidjson",
	},
}

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

	local standardizedUpdateBranchName = string.lower(format("%s-update-latest", submodule.abbreviatedName))
	local standardizedUpdateCommitMessage = format('"Deps: Update %s to the latest HEAD"', submodule.displayName)

	printf("Committing changes for submodule %s to branch %s", submodule.displayName, standardizedUpdateBranchName)
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

local submoduleToUpdate = submodules[submoduleID]
if not submoduleToUpdate then
	printf("Cannot upgrade submodule (invalid submodule ID: %s)", submoduleID)
	printf("Valid submodule IDs are: %s", table.concat(table_keys(submodules), ", "))
	os.exit(1)
end

SubmoduleUpdater:ResetSubmoduleState(submoduleToUpdate)
SubmoduleUpdater:FetchLatestChangesForSubmodule(submoduleToUpdate)
SubmoduleUpdater:CommitLatestChangesForSubmodule(submoduleToUpdate)
