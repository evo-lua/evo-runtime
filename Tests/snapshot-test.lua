local assertions = require("assertions")
local evo = require("evo")
local ffi = require("ffi")
local uv = require("uv")
local vfs = require("vfs")

local assertEquals = assertions.assertEquals
local assertTrue = assertions.assertTrue

local isWindows = ffi.os == "Windows"
local EXECUTABLE_SUFFIX = isWindows and ".exe" or ""

local testCases = {
	["cli-no-args"] = {
		humanReadableDescription = "Invoking the CLI without passing any arguments should print the help text",
		programToRun = "evo",
		onExit = function(observedOutput)
			local helpText = evo.getHelpText()
			local versionText = evo.getVersionText()
			local documentationLinkText = "For documentation and examples, visit https://evo-lua.github.io/"

			assertEquals(observedOutput, helpText .. "\n" .. versionText .. "\n" .. documentationLinkText .. "\n")
		end,
	},
	["cli-help-text"] = {
		humanReadableDescription = "Invoking the CLI help command should print the help text",
		programToRun = "evo help",
		onExit = function(observedOutput)
			local helpText = evo.getHelpText()
			local versionText = evo.getVersionText()
			local documentationLinkText = "For documentation and examples, visit https://evo-lua.github.io/"

			assertEquals(observedOutput, helpText .. "\n" .. versionText .. "\n" .. documentationLinkText .. "\n")
		end,
	},
	["cli-version-text"] = {
		humanReadableDescription = "Invoking the CLI version command should print the runtime version only",
		programToRun = "evo version",
		onExit = function(observedOutput)
			local VERSION_PATTERN = "(%d+.%d+.%d+).*"
			local runtimeVersion = observedOutput:match("^v" .. VERSION_PATTERN .. "$")
			local hasRuntimeVersion = (runtimeVersion ~= nil)
			assertTrue(hasRuntimeVersion)
		end,
	},
	["cli-eval-nil"] = {
		humanReadableDescription = "Invoking the CLI eval command with no arguments should print nothing",
		programToRun = "evo eval",
		onExit = function(observedOutput)
			assertEquals(observedOutput, "")
		end,
	},
	["cli-eval-chunk"] = {
		humanReadableDescription = "Invoking the CLI eval command with a valid chunk should print the result",
		programToRun = 'evo eval "print(42)"',
		onExit = function(observedOutput)
			assertEquals(observedOutput, "42\n")
		end,
	},
	["cli-build-cwd"] = {
		humanReadableDescription = "Invoking the CLI build command with no arguments should try to build from cwd",
		programToRun = "evo build",
		onExit = function(observedOutput)
			local executableName = "evo-runtime" .. EXECUTABLE_SUFFIX
			assertEquals(
				observedOutput,
				"No inputs given, building from the current working directory\n"
					.. "Cannot create self-contained executable: "
					.. executableName
					.. "\n"
					.. "main.lua not found - without an entry point, your app won't be able to run!\n"
			)
		end,
	},
	["cli-build-success"] = {
		humanReadableDescription = "Invoking the CLI build command with a valid app directory should build an executable",
		programToRun = "evo build Tests/Fixtures/hello-world-app",
		onExit = function(observedOutput)
			local executableName = "hello-world-app" .. EXECUTABLE_SUFFIX
			local fullAppDirectoryPath = path.join(uv.cwd(), "Tests/Fixtures/hello-world-app")

			local runtimeExecutableBytes = C_FileSystem.ReadFile(uv.exepath())
			local runtimeExeSize = #runtimeExecutableBytes
			local zipAppBytes = C_FileSystem.ReadFile(executableName)
			local zipApp = vfs.decode(zipAppBytes)
			local zipAppSize = #zipApp.archive
			local totalFileSize = uv.fs_stat(path.join(fullAppDirectoryPath, "main.lua")).size
				+ uv.fs_stat(path.join(fullAppDirectoryPath, "some-file.txt")).size
				+ uv.fs_stat(path.join(fullAppDirectoryPath, "subdirectory", "another-file.lua")).size

			local expectedOutput = format("Building from %s\n", fullAppDirectoryPath)
				.. format("Adding file: main.lua\n")
				.. format("Adding file: some-file.txt\n")
				.. format("Adding file: %s\n", path.join("subdirectory", "another-file.lua"))
				.. format(
					"Archived 3 files (%s) - total size: %s\n",
					string.filesize(totalFileSize),
					string.filesize(zipAppSize)
				)
				.. format("Created miniz archive: %s\n", "hello-world-app.zip")
				.. format("Embedding signature: LUAZIP 1.0 (EXE: %d, ZIP: %d)\n", runtimeExeSize, zipAppSize)
				.. format("Created self-contained executable: %s\n", executableName)

			assertEquals(observedOutput, expectedOutput)
		end,
	},
	["cli-build-invalid-dir"] = {
		humanReadableDescription = "Invoking the CLI build command while passing an invalid directory should fail",
		programToRun = "evo build does-not-exist",
		onExit = function(observedOutput)
			local executableName = "does-not-exist" .. EXECUTABLE_SUFFIX
			assertEquals(
				observedOutput,
				"Cannot create self-contained executable: "
					.. executableName
					.. "\n"
					.. "Not a directory: does-not-exist"
					.. "\n"
					.. "Please make sure a directory with this name exists (and contains main.lua)\n"
			)
		end,
	},
	["cli-build-file"] = {
		humanReadableDescription = "Invoking the CLI build command while passing a file instead of a directory should fail",
		programToRun = "evo build Tests/Fixtures/hello-world-app/main.lua",
		onExit = function(observedOutput)
			local executableName = "main.lua" .. EXECUTABLE_SUFFIX
			assertEquals(
				observedOutput,
				"Cannot create self-contained executable: "
					.. executableName
					.. "\n"
					.. "Not a directory: Tests/Fixtures/hello-world-app/main.lua"
					.. "\n"
					.. "Please make sure a directory with this name exists (and contains main.lua)\n"
			)
		end,
	},
}

C_Runtime.RunSnapshotTests(testCases)

-- This relies on the hello-world-app being built first, but the order is not guaranteed
testCases = {
	["cli-hello-world-app"] = {
		humanReadableDescription = "Invoking the hello world app should execute the bundled app instead of the runtime CLI",
		programToRun = ffi.os ~= "Windows" and "chmod +x hello-world-app && ./hello-world-app" or "hello-world-app.exe",
		onExit = function(observedOutput)
			assertEquals(observedOutput, "Hello world!\n")
		end,
	},
}

C_Runtime.RunSnapshotTests(testCases)

C_FileSystem.Delete("hello-world-app.zip")
C_FileSystem.Delete("hello-world-app" .. EXECUTABLE_SUFFIX)
