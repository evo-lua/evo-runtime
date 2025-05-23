local assertions = require("assertions")
local bdd = require("bdd")
local ffi = require("ffi")
local runtime = require("runtime")
local transform = require("transform")
local uv = require("uv")
local validation = require("validation")

-- This namespace is created in C++ land, so just assume it exists here
local C_Runtime = _G.C_Runtime

function C_Runtime.RunBasicTests(specFiles)
	validation.validateTable(specFiles, "specFiles")

	package.open(assertions)

	bdd.setBasicReportMode()
	local numFailedTests = bdd.startTestRunner(specFiles)

	print(bdd.getReport())

	local errorDetails = bdd.getErrorDetails()
	for index, errorInfo in ipairs(table.reverse(errorDetails)) do
		print(format("(Error #%d) in %s", index, transform.bold(errorInfo.specFile)))
		print(transform.brightRed(errorInfo.stackTrace))
		print()
	end

	return numFailedTests
end

function C_Runtime.RunMinimalTests(specFiles)
	validation.validateTable(specFiles, "specFiles")

	package.open(assertions)

	bdd.setMinimalReportMode()
	local numFailedTests = bdd.startTestRunner(specFiles)

	print(bdd.getReport())

	local errorDetails = bdd.getErrorDetails()
	for index, errorInfo in ipairs(table.reverse(errorDetails)) do
		print(format("(Error #%d) in %s", index, transform.bold(errorInfo.specFile)))
		print(transform.brightRed(errorInfo.stackTrace))
		print()
	end

	return numFailedTests
end

function C_Runtime.RunDetailedTests(specFiles)
	validation.validateTable(specFiles, "specFiles")

	package.open(assertions)

	bdd.setDetailedReportMode()
	local numFailedTests = bdd.startTestRunner(specFiles)

	print(bdd.getReport())

	local errorDetails = bdd.getErrorDetails()
	for index, errorInfo in ipairs(table.reverse(errorDetails)) do
		print(format("(Error #%d) in %s", index, transform.bold(errorInfo.specFile)))
		print(transform.brightRed(errorInfo.stackTrace))
		print()
	end

	return numFailedTests
end

function C_Runtime.EvaluateString(luaCode)
	validation.validateString(luaCode, "luaCode")
	return load(luaCode)()
end

function C_Runtime.PrintVersionString()
	local semanticVersionString = runtime.version()
	print(semanticVersionString)
end

local function shell_exec(command, environmentVariables)
	environmentVariables = environmentVariables or {}
	local tempFile, tempFileName = uv.fs_mkstemp("evo-runtime-test-XXXXXX")
	assert(tempFile, tempFileName)
	-- An open FD may block the spawned process from writing on Windows
	assert(uv.fs_close(tempFile))

	for name, value in pairs(environmentVariables) do
		printf("Setting environment variable %s to %s", name, value)
		uv.os_setenv(name, value)
	end
	local commandWithRedirection = command .. " > " .. tempFileName .. " 2>&1"

	-- Somewhat sketchy, but portable enough for this use case?
	local success, terminationReason, exitCode = os.execute(commandWithRedirection)

	for name, value in pairs(environmentVariables) do
		printf("Resetting environment variable %s", name)
		uv.os_unsetenv(name, value)
	end

	local output = C_FileSystem.ReadFile(tempFileName)
	C_FileSystem.Delete(tempFileName) -- FD already closed, so manual cleanup is required
	if ffi.os == "Windows" then
		-- Have to normalize to get rid of MS idiosyncracies
		output = output:gsub("%s?\r\n", "\n")
	end
	return output, success, terminationReason, exitCode
end

function C_Runtime.RunSnapshotTests(testCases)
	validation.validateTable(testCases, "testCases")

	for descriptor, testInfo in pairs(testCases) do
		validation.validateString(testInfo.programToRun, "programToRun")
		validation.validateFunction(testInfo.onExit, "onExit")

		printf("Running snapshot test %s", transform.bold(descriptor))
		printf("[SHELL] Executing command: %s", transform.green(testInfo.programToRun))
		local observedOutput, status, terminationReason, exitCodeOrSignalID =
			shell_exec(testInfo.programToRun, testInfo.environmentVariables)
		printf("[SHELL] Observed output has %d bytes", #observedOutput)
		printf("[SHELL] Termination status: %s", status)
		printf("[SHELL] Termination reason: %s", terminationReason)
		printf("[SHELL] Return code or signal: %s", exitCodeOrSignalID)
		testInfo.onExit(observedOutput, status, terminationReason, exitCodeOrSignalID)
	end
end

return C_Runtime
