local assertions = require("assertions")
local bdd = require("bdd")
local transform = require("transform")

local format = string.format

-- All paths are relative to the project root, since that's where the CI run will start
local specFiles = {
	"Tests/BDD/placeholder.spec.lua",
}

local function runBasicTests()
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

local function runDetailedTests()
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

assertions.export() -- Should probably remove this after global aliases are set up by the runtime

local numFailedSpecFiles = runBasicTests()
local numFailedSections = runDetailedTests()

os.exit(math.max(numFailedSpecFiles, numFailedSections))
