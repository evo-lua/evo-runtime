local assertions = require("assertions")
local bdd = require("bdd")
local evo = require("evo")
local ffi = require("ffi")
local uv = require("uv")
local transform = require("transform")
local vfs = require("vfs")

local assertEquals = assertions.assertEquals
local assertNil = assertions.assertNil
local assertTrue = assertions.assertTrue

local isWindows = ffi.os == "Windows"
local EXECUTABLE_SUFFIX = isWindows and ".exe" or ""

local EXIT_SUCCESS = 0
local EXIT_FAILURE = 1

local function assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
	assertTrue(status)
	assertEquals(terminationReason, "exit")
	assertEquals(exitCodeOrSignalID, EXIT_SUCCESS)
end

local function assertExitFailure(observedOutput, status, terminationReason, exitCodeOrSignalID)
	assertNil(status)
	assertEquals(terminationReason, "exit")
	assertEquals(exitCodeOrSignalID, EXIT_FAILURE)
end

local function fixUpReportString(reportString)
	-- Relying on timings to be identical will only cause flakiness
	return reportString:gsub("complete %(%d* ms%)", "complete (0 ms)")
end

local function simulateDetailedTestRunWithInputs(specFiles)
	-- Since the test itself is executed in another process, mirror it here to create a matching report
	bdd.setDetailedReportMode()
	local numFailedTests = bdd.startTestRunner(specFiles)
	-- Failing tests aren't used here as the stack traces would make matching report strings difficult
	assertEquals(numFailedTests, 0)
	local reportString = bdd.getReport()
	reportString = fixUpReportString(reportString)

	-- The bdd test runner may be started multiple times as part of the snapshot test suite
	bdd.reset()

	return reportString
end

-- Working around cmd.exe idiosyncracies ...
local DOUBLE_QUOTE = '"'
local SINGLE_QUOTE = "'"
local SHELL_ESCAPE_SYMBOL = isWindows and "" or DOUBLE_QUOTE
local STRING_ESCAPE_SYMBOL = isWindows and DOUBLE_QUOTE or SINGLE_QUOTE

local testCases = {
	["cli-no-args"] = {
		humanReadableDescription = "Invoking the CLI without passing any arguments should print the help text",
		programToRun = "evo",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local helpText = evo.getHelpText()
			local versionText = evo.getVersionText()
			local documentationLinkText = evo.messageStrings.HELP_COMMAND_DOCUMENTATION_LINK

			assertEquals(observedOutput, helpText .. "\n" .. versionText .. "\n" .. documentationLinkText .. "\n")
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-run-script"] = {
		humanReadableDescription = "Invoking the CLI with a Lua script path should execute the script with the provided args",
		programToRun = "evo Tests/Fixtures/hello-world-app/main.lua hi",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local expectedOutput = "Hello world!\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-help-text"] = {
		humanReadableDescription = "Invoking the CLI help command should print the help text",
		programToRun = "evo help",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local helpText = evo.getHelpText()
			local versionText = evo.getVersionText()
			local documentationLinkText = evo.messageStrings.HELP_COMMAND_DOCUMENTATION_LINK

			assertEquals(observedOutput, helpText .. "\n" .. versionText .. "\n" .. documentationLinkText .. "\n")
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-version-text"] = {
		humanReadableDescription = "Invoking the CLI version command should print the runtime version only",
		programToRun = "evo version",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local VERSION_PATTERN = "(%d+.%d+.%d+).*"
			local runtimeVersion = observedOutput:match("^v" .. VERSION_PATTERN .. "$")
			local hasRuntimeVersion = (runtimeVersion ~= nil)
			assertTrue(hasRuntimeVersion)
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-eval-repl"] = {
		humanReadableDescription = "Invoking the CLI eval command with no arguments should start the REPL",
		-- Sending via stdin to the REPL ensures that it exits (and doesn't hang the test)
		programToRun = "echo "
			.. SHELL_ESCAPE_SYMBOL
			.. "print("
			.. STRING_ESCAPE_SYMBOL
			.. "Hello from the REPL!"
			.. STRING_ESCAPE_SYMBOL
			.. "); os.exit(1, true)"
			.. SHELL_ESCAPE_SYMBOL
			.. " | evo eval",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local expectedOutput = evo.messageStrings.REPL_WELCOME_TEXT
				.. "\n"
				.. evo.messageStrings.REPL_USAGE_INSTRUCTIONS
				.. "\n"
				.. "> Hello from the REPL!"
				.. "\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitFailure(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-eval-chunk"] = {
		humanReadableDescription = "Invoking the CLI eval command with a valid chunk should print the result",
		programToRun = 'evo eval "print(42)"',
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			assertEquals(observedOutput, "42\n")
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-build-cwd"] = {
		humanReadableDescription = "Invoking the CLI build command with no arguments should try to build from cwd",
		programToRun = "evo build",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local executableName = "evo-runtime" .. EXECUTABLE_SUFFIX
			local expectedOutput = format("Building from %s", transform.bold(uv.cwd()))
				.. "\n"
				.. format(
					transform.brightRed(evo.errorStrings.APP_BUNDLER_ENTRY_POINT_MISSING),
					executableName,
					evo.DEFAULT_ENTRY_POINT
				)
				.. "\n\n"
				.. evo.messageStrings.BUILD_COMMAND_USAGE_INFO
				.. "\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitFailure(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-build-success"] = {
		humanReadableDescription = "Invoking the CLI build command with a valid app directory should build an executable",
		programToRun = "evo build Tests/Fixtures/hello-world-app",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local executableName = "hello-world-app" .. EXECUTABLE_SUFFIX
			local fullAppDirectoryPath = path.join(uv.cwd(), "Tests/Fixtures/hello-world-app")

			local runtimeExecutableBytes = C_FileSystem.ReadFile(uv.exepath())
			local runtimeExeSize = #runtimeExecutableBytes
			local zipAppBytes = C_FileSystem.ReadFile(executableName)
			local zipApp = vfs.decode(zipAppBytes)
			local zipAppSize = #zipApp.archive
			local totalFileSize = uv.fs_stat(path.join(fullAppDirectoryPath, "main.lua")).size
				+ uv.fs_stat(path.join(fullAppDirectoryPath, "conflicting.lua")).size
				+ uv.fs_stat(path.join(fullAppDirectoryPath, "searchable.lua")).size
				+ uv.fs_stat(path.join(fullAppDirectoryPath, "some-file.txt")).size
				+ uv.fs_stat(path.join(fullAppDirectoryPath, "subdirectory", "another-file.lua")).size

			local expectedOutput = format("Building from %s\n", transform.bold(fullAppDirectoryPath))
				.. format(transform.magenta("Adding file: conflicting.lua"))
				.. "\n"
				.. format(transform.magenta("Adding file: main.lua"))
				.. "\n"
				.. format(transform.magenta("Adding file: searchable.lua"))
				.. "\n"
				.. format(transform.magenta("Adding file: some-file.txt"))
				.. "\n"
				.. format(transform.magenta("Adding file: %s"), path.join("subdirectory", "another-file.lua"))
				.. "\n"
				.. format(
					transform.brightGreen("Archived 5 files (%s) - total size: %s") .. "\n",
					string.filesize(totalFileSize),
					string.filesize(zipAppSize)
				)
				.. format("Created miniz archive: %s\n", transform.brightYellow("hello-world-app.zip"))
				.. format(
					transform.brightGreen("Embedding signature: LUAZIP 1.0 (EXE: %d, ZIP: %d)"),
					runtimeExeSize,
					zipAppSize
				)
				.. "\n"
				.. format("Created self-contained executable: %s\n", transform.brightYellow(executableName))
			assertEquals(observedOutput, expectedOutput)
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-build-invalid-dir"] = {
		humanReadableDescription = "Invoking the CLI build command while passing an invalid directory should fail",
		programToRun = "evo build does-not-exist",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local executableName = "does-not-exist" .. EXECUTABLE_SUFFIX
			local expectedOutput = format(
				transform.brightRed(evo.errorStrings.APP_BUNDLER_INVALID_BUILD_DIR),
				executableName,
				"does-not-exist"
			) .. "\n\n" .. evo.messageStrings.BUILD_COMMAND_USAGE_INFO .. "\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitFailure(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-build-file"] = {
		humanReadableDescription = "Invoking the CLI build command while passing a file instead of a directory should fail",
		programToRun = "evo build Tests/Fixtures/hello-world-app/main.lua",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local executableName = "main.lua" .. EXECUTABLE_SUFFIX
			local inputFilePath = "Tests/Fixtures/hello-world-app/main.lua"
			local expectedOutput = format(
				transform.brightRed(evo.errorStrings.APP_BUNDLER_INVALID_BUILD_DIR),
				executableName,
				inputFilePath
			) .. "\n\n" .. evo.messageStrings.BUILD_COMMAND_USAGE_INFO .. "\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitFailure(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-test-noargs-error"] = {
		humanReadableDescription = "Invoking the test command without args should print an error if test.lua doesn't exist",
		programToRun = "evo test",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local expectedOutput = transform.brightRed(evo.errorStrings.TEST_RUNNER_ENTRY_POINT_MISSING)
				.. "\n\n"
				.. evo.messageStrings.TEST_COMMAND_USAGE_INFO
				.. "\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitFailure(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-test-noargs-error-with-app-args"] = {
		humanReadableDescription = "Invoking the test command without args but with app args should print an error if test.lua doesn't exist",
		programToRun = "evo test --integration",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local expectedOutput = transform.brightRed(evo.errorStrings.TEST_RUNNER_ENTRY_POINT_MISSING)
				.. "\n\n"
				.. evo.messageStrings.TEST_COMMAND_USAGE_INFO
				.. "\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitFailure(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-test-multiple-existing-files"] = {
		humanReadableDescription = "Invoking the test command with existing file paths should load them as tests",
		programToRun = "evo test Tests/Fixtures/test-dir/subdir/lua-test-file.lua Tests/Fixtures/test-dir/lua-spec-file.spec.lua",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local specFiles = {
				"Tests/Fixtures/test-dir/subdir/lua-test-file.lua",
				"Tests/Fixtures/test-dir/lua-spec-file.spec.lua",
			}
			local expectedReportString = simulateDetailedTestRunWithInputs(specFiles)
			local expectedOutputLines = {
				"OK: Loading test file from subdirectory",
				"OK: Loading spec file from directory",
				"OK: section ran",
				"OK: subsection ran",
			}
			local expectedOutput = table.concat(expectedOutputLines, "\n") .. "\n" .. expectedReportString .. "\n"

			observedOutput = fixUpReportString(observedOutput)
			assertEquals(observedOutput, expectedOutput)
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-test-existing-files-and-dirs"] = {
		humanReadableDescription = "Invoking the test command with existing file and directory paths should load all included .lua files as tests",
		programToRun = "evo test Tests/Fixtures/test-dir/lua-spec-file.spec.lua Tests/Fixtures/test-dir",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local specFiles = {
				"Tests/Fixtures/test-dir/lua-spec-file.spec.lua",
				"Tests/Fixtures/test-dir/lua-spec-file.spec.lua",
				"Tests/Fixtures/test-dir/subdir/lua-test-file.lua",
			}
			local expectedReportString = simulateDetailedTestRunWithInputs(specFiles)
			local expectedOutputLines = {
				"OK: Loading spec file from directory",
				"OK: section ran",
				"OK: subsection ran",
				"OK: Loading spec file from directory",
				"OK: section ran",
				"OK: subsection ran",
				"OK: Loading test file from subdirectory",
			}
			local expectedOutput = table.concat(expectedOutputLines, "\n") .. "\n" .. expectedReportString .. "\n"

			observedOutput = fixUpReportString(observedOutput)
			assertEquals(observedOutput, expectedOutput)
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},

	["cli-test-cannot-load-file"] = {
		humanReadableDescription = "Invoking the test command with non-Lua script files should fail with an error",
		programToRun = "evo test Tests/Fixtures/test-dir/lua-spec-file.spec.lua Tests/Fixtures/test-dir/not-a-lua-file.txt",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local expectedOutput = transform.brightRed(
				format(evo.errorStrings.TEST_RUNNER_CANNOT_LOAD, "Tests/Fixtures/test-dir/not-a-lua-file.txt")
			) .. "\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitFailure(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-test-cannot-open-file"] = {
		humanReadableDescription = "Invoking the test command with invalid file paths should fail with an error",
		programToRun = "evo test Tests/Fixtures/test-dir/lua-spec-file.spec.lua Tests/Fixtures/test-dir/does-not-exist.lua",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local expectedOutput = transform.brightRed(
				format(evo.errorStrings.TEST_RUNNER_CANNOT_OPEN, "Tests/Fixtures/test-dir/does-not-exist.lua")
			) .. "\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitFailure(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-test-cannot-open-dir"] = {
		humanReadableDescription = "Invoking the test command with invalid directory paths should fail with an error",
		programToRun = "evo test Tests/Fixtures/test-dir/lua-spec-file.spec.lua Tests/Fixtures/test-dir/does-not-exist",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local expectedOutput = transform.brightRed(
				format(evo.errorStrings.TEST_RUNNER_CANNOT_OPEN, "Tests/Fixtures/test-dir/does-not-exist")
			) .. "\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitFailure(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-test-profile-noargs"] = {
		humanReadableDescription = "Invoking the profile command without args should display a help text ",
		programToRun = "evo profile",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local expectedOutput = evo.messageStrings.PROFILE_COMMAND_USAGE_INFO .. "\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitFailure(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-test-profile-env-vars"] = {
		humanReadableDescription = "Invoking the profile command without args should display a help text ",
		programToRun = "evo profile Tests/Fixtures/empty.spec.lua",
		environmentVariables = {
			LUAJIT_PROFILEFILE = "results.txt",
			LUAJIT_PROFILEMODE = "3si4m1",
		},
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local expectedOutput = "Detected LUAJIT_PROFILEMODE: 3si4m1\n"
				.. "Detected LUAJIT_PROFILEFILE: results.txt\n"
			local profilingResults = C_FileSystem.ReadFile("results.txt")
			C_FileSystem.Delete("results.txt")
			profilingResults = profilingResults:gsub("\r\n", "\n") -- LuaJIT opens the file in text mode
			assertEquals(observedOutput, expectedOutput)
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
			assertEquals(profilingResults, "[No samples collected]\n")
		end,
	},
	["cli-debug-events"] = {
		humanReadableDescription = "Invoking the CLI debug command while passing a file that records events should display them",
		programToRun = "evo debug Tests/Fixtures/etrace-test.lua",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local separator = string.rep("-", #evo.messageStrings.EVENT_TRACING_NOTICE)
			local expectedTraceLog = require("Tests.Fixtures.etrace-test")
			local expectedOutput = evo.messageStrings.EVENT_TRACING_NOTICE
				.. "\n"
				.. separator
				.. "\n"
				.. expectedTraceLog
				.. "\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-debug-no-events"] = {
		humanReadableDescription = "Invoking the CLI debug command while passing a file that doesn't record events should not display event log entries",
		programToRun = "evo debug Tests/Fixtures/empty.spec.lua",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local separator = string.rep("-", #evo.messageStrings.EVENT_TRACING_NOTICE)
			local expectedOutput = evo.messageStrings.EVENT_TRACING_NOTICE .. "\n" .. separator .. "\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-debug-noargs"] = {
		humanReadableDescription = "Invoking the debug command without args should display a help text ",
		programToRun = "evo debug",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local expectedOutput = evo.messageStrings.DEBUG_COMMAND_USAGE_INFO .. "\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitFailure(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
}

C_Runtime.RunSnapshotTests(testCases)

testCases = {
	-- This relies on the hello-world-app being built first, but the order is not guaranteed
	["cli-hello-world-app"] = {
		humanReadableDescription = "Invoking the hello world app should execute the bundled app instead of the runtime CLI with the provided args",
		programToRun = ffi.os ~= "Windows" and "./hello-world-app hi" or "hello-world-app.exe hi",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			assertEquals(observedOutput, "Hello world!\n")
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	-- This one interferes with the build tests as it requires creating temporary files
	["cli-run-cwd"] = {
		humanReadableDescription = "Invoking the CLI with a single dot should execute main.lua",
		programToRun = "evo .",
		-- Assumes the entry point has been created prior to running the test suite, which it should have
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local expectedOutput = "Hello from main.lua\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-test-noargs"] = {
		humanReadableDescription = "Invoking the test command without args should run test.lua if it exists",
		programToRun = "evo test",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local expectedOutput = "Hello from test.lua (app args: 0, nil, nil)\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
	["cli-test-noargs-forward"] = {
		humanReadableDescription = "Invoking the test command without args but with app args should run test.lua and forward the app args",
		programToRun = "evo test --integration --asdf",
		onExit = function(observedOutput, status, terminationReason, exitCodeOrSignalID)
			local expectedOutput = "Hello from test.lua (app args: 2, integration, asdf)\n"
			assertEquals(observedOutput, expectedOutput)
			assertExitSuccess(observedOutput, status, terminationReason, exitCodeOrSignalID)
		end,
	},
}

C_FileSystem.WriteFile("conflicting.lua", "return {checksum=0}")
C_FileSystem.WriteFile("main.lua", "print('Hello from main.lua')")
C_FileSystem.WriteFile(
	"test.lua",
	"assertEquals(42, 42); printf('Hello from test.lua (app args: %d, %s, %s)', #arg, tostring(arg[1]), tostring(arg[2]))"
)

C_Runtime.RunSnapshotTests(testCases)

C_FileSystem.Delete("hello-world-app.zip")
C_FileSystem.Delete("hello-world-app" .. EXECUTABLE_SUFFIX)
C_FileSystem.Delete("main.lua")
C_FileSystem.Delete("conflicting.lua")
C_FileSystem.Delete("test.lua")
