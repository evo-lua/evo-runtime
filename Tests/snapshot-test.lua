local assertions = require("assertions")
local evo = require("evo")

local assertEquals = assertions.assertEquals
local assertTrue = assertions.assertTrue

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
}

C_Runtime.RunSnapshotTests(testCases)
