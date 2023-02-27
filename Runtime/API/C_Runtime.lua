local assertions = require("assertions")
local bdd = require("bdd")
local transform = require("transform")
local validation = require("validation")

-- This namespace is created in C++ land, so just assume it exists here
local C_Runtime = _G.C_Runtime

function C_Runtime.RunBasicTests(specFiles)
	validation.validateTable(specFiles, "specFiles")

	assertions.export() -- Should probably remove this after global aliases are set up by the runtime

	bdd.setBasicReportMode()
	local numFailedTests = bdd.startTestRunner(specFiles)

	print(bdd.getReport())

	local errorDetails = bdd.getErrorDetails()
	for index, errorInfo in ipairs(errorDetails) do
		print(format("(Error #%d) in %s", index, transform.bold(errorInfo.specFile)))
		print(transform.brightRed(errorInfo.stackTrace))
		print()
	end

	return numFailedTests
end

function C_Runtime.RunMinimalTests(specFiles)
	validation.validateTable(specFiles, "specFiles")

	assertions.export() -- Should probably remove this after global aliases are set up by the runtime

	bdd.setMinimalReportMode()
	local numFailedTests = bdd.startTestRunner(specFiles)

	print(bdd.getReport())

	local errorDetails = bdd.getErrorDetails()
	for index, errorInfo in ipairs(errorDetails) do
		print(format("(Error #%d) in %s", index, transform.bold(errorInfo.specFile)))
		print(transform.brightRed(errorInfo.stackTrace))
		print()
	end

	return numFailedTests
end

function C_Runtime.RunDetailedTests(specFiles)
	validation.validateTable(specFiles, "specFiles")

	assertions.export() -- Should probably remove this after global aliases are set up by the runtime

	bdd.setDetailedReportMode()
	local numFailedTests = bdd.startTestRunner(specFiles)

	print(bdd.getReport())

	local errorDetails = bdd.getErrorDetails()
	for index, errorInfo in ipairs(errorDetails) do
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
	print(_G.EVO_VERSION)
end

return C_Runtime
