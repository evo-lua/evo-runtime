local buffer = require("string.buffer")
local transform = require("transform")
local uv = require("uv")
local validation = require("validation")

local bold = transform.bold
local brightRed = transform.brightRed
local green = transform.green
local yellow = transform.yellow

local validateFunction = validation.validateFunction
local validateString = validation.validateString
local validateTable = validation.validateTable

local dofile = dofile
local print = print

local format = string.format
local string_rep = string.rep
local table_insert = table.insert

local bdd = {
	lastExecutedSpecFile = nil,
	registeredSetupFunctions = {},
	registeredTeardownFunctions = {},
	startTime = 0,
	endTime = 0,
	numCompletedTests = 0,
	numFailedTests = 0,
	reportIndentationLevel = 0,
	reportBuffer = buffer.new(),
	MINIMAL_REPORTING_MODE = "MINIMAL",
	BASIC_REPORTING_MODE = "BASIC",
	DETAILED_REPORTING_MODE = "DETAILED",
	reportingMode = "DETAILED",
	errorDetails = {},
}

function bdd.startTestRunner(specFiles)
	validateTable(specFiles, "specFiles")

	if #specFiles == 0 then
		error("No test cases to run", 0)
	end

	bdd.reset()

	if bdd.isBasicReportingMode() then
		local numSpecFiles = tostring(#specFiles)
		bdd.report("Test runner started with a total of " .. bold(numSpecFiles) .. " spec file(s)")
		bdd.report("")
	end

	bdd.startTime = uv.hrtime()

	for _, specFile in ipairs(specFiles) do
		bdd.executeSpecFile(specFile)
	end

	bdd.endTime = uv.hrtime()

	if bdd.isBasicReportingMode() then
		bdd.report("")
		bdd.report("Finished running all tests in " .. bdd.getElapsedTime())
	elseif bdd.isDetailedReportingMode() then
		bdd.report(bdd.getSectionsReportString())
	end

	return bdd.numFailedTests
end

function bdd.getElapsedTime()
	local elapsedTimeInNanoseconds = bdd.endTime - bdd.startTime
	return bdd.getHumanReadableTime(elapsedTimeInNanoseconds)
end

local NANOSECONDS_PER_MILLISECOND = 10E5
local NANOSECONDS_PER_MICROSECOND = 1000
local MILLISECONDS_PER_SECOND = 1000

function bdd.getHumanReadableTime(highResolutionTime)
	local nanoseconds = highResolutionTime
	local microseconds = nanoseconds / NANOSECONDS_PER_MICROSECOND
	local milliseconds = nanoseconds / NANOSECONDS_PER_MILLISECOND
	local seconds = milliseconds / MILLISECONDS_PER_SECOND

	if seconds > 1 then
		return format("%.2f seconds", seconds)
	elseif milliseconds > 1 then
		return format("%.2f ms", milliseconds)
	elseif microseconds > 1 then
		return format("%d µs", microseconds)
	else
		return format("%d ns", nanoseconds)
	end
end

local function errorHandler(errorMessage)
	if errorMessage == "" then
		return
	end

	local stackTrace = debug.traceback(errorMessage, 3)
	-- Level 3 strips this error handler and the [C] error call
	return {
		message = debug.tostring(errorMessage),
		stackTrace = debug.tostring(stackTrace),
	}
end

function bdd.executeSpecFile(specFile)
	validateString(specFile, "specFile")

	local fileStats, errorMessage = uv.fs_stat(specFile)
	if not fileStats and errorMessage == "ENOENT: no such file or directory: " .. specFile then
		-- Use the same error as the standard Lua dofile would to keep things consistent
		error("cannot open " .. specFile .. ": No such file or directory", 0)
	end

	bdd.lastExecutedSpecFile = specFile

	local success, errorDetails = xpcall(dofile, errorHandler, specFile)
	if not success then
		errorMessage = errorDetails.message
		errorDetails.specFile = specFile
		table_insert(bdd.errorDetails, errorDetails)
	end

	if bdd.isBasicReportingMode() then
		if success then
			bdd.report(green("PASS" .. "\t" .. specFile))
		else
			bdd.report(transform.brightRed("FAIL" .. "\t" .. specFile))
			bdd.numFailedTests = bdd.numFailedTests + 1
		end
	end

	if not success and (bdd.isMinimalReportingMode() or bdd.isDetailedReportingMode()) then
		-- Relying on just the exit code may be a bit too minimal, so let's fail loudly here
		error(errorMessage, 0)
	end

	return success, errorMessage
end

function bdd.getErrorDetails()
	return bdd.errorDetails
end

function bdd.setMinimalReportMode()
	bdd.reportingMode = bdd.MINIMAL_REPORTING_MODE
end

function bdd.isMinimalReportingMode()
	return (bdd.reportingMode == bdd.MINIMAL_REPORTING_MODE)
end

function bdd.setBasicReportMode()
	bdd.reportingMode = bdd.BASIC_REPORTING_MODE
end

function bdd.isBasicReportingMode()
	return (bdd.reportingMode == bdd.BASIC_REPORTING_MODE)
end

function bdd.setDetailedReportMode()
	bdd.reportingMode = bdd.DETAILED_REPORTING_MODE
end

function bdd.isDetailedReportingMode()
	return (bdd.reportingMode == bdd.DETAILED_REPORTING_MODE)
end

function bdd.report(message)
	bdd.reportBuffer:put(message)
	bdd.reportBuffer:put("\n") -- For print-like semantics
end

function bdd.getReport()
	return tostring(bdd.reportBuffer)
end

function bdd.startSection(label, testFunction)
	validateString(label, "label")
	validateFunction(testFunction, "testFunction")

	if not bdd.isDetailedReportingMode() then
		local warningString = format(
			'WARNING: Encountered BDD-style section with label "%s", but reporting mode is not %s',
			label,
			bdd.DETAILED_REPORTING_MODE
		)
		print(yellow(warningString))
		return
	end

	bdd.reportSection(label)
	local setupStackSnapshot = { unpack(bdd.registeredSetupFunctions) }
	local teardownStackSnapshot = { unpack(bdd.registeredTeardownFunctions) }

	bdd.registeredSetupFunctions = {}
	bdd.registeredTeardownFunctions = {}

	bdd.reportIndentationLevel = bdd.reportIndentationLevel + 1

	testFunction()

	bdd.registeredSetupFunctions = setupStackSnapshot
	bdd.registeredTeardownFunctions = teardownStackSnapshot

	bdd.reportIndentationLevel = bdd.reportIndentationLevel - 1
end

function bdd.startSubsection(label, testFunction)
	validateString(label, "label")
	validateFunction(testFunction, "testFunction")

	if not bdd.isDetailedReportingMode() then
		local warningString = format(
			'WARNING: Encountered BDD-style subsection with label "%s", but reporting mode is not %s',
			label,
			bdd.DETAILED_REPORTING_MODE
		)
		print(yellow(warningString))
		return
	end

	for _, setupFunction in ipairs(bdd.registeredSetupFunctions) do
		setupFunction()
	end

	local success, errorDetails = xpcall(testFunction, errorHandler)
	print(success, errorDetails)
	for _, teardownFunction in ipairs(bdd.registeredTeardownFunctions) do
		teardownFunction()
	end

	if success then
		bdd.reportPassingSubsection(label)
		bdd.numCompletedTests = bdd.numCompletedTests + 1
	else
		bdd.reportFailingSubsection(label)
		bdd.numFailedTests = bdd.numFailedTests + 1

		errorDetails.specFile = bdd.lastExecutedSpecFile
		table_insert(bdd.errorDetails, errorDetails)
	end
end

function bdd.reportSection(label)
	local indent = bdd.reportIndentationLevel
	local indentPrefix = string.rep("  ", indent)

	bdd.report(indentPrefix .. bold(label))
end

function bdd.reportPassingSubsection(label)
	local icon = green("✓")

	local indent = bdd.reportIndentationLevel
	local indentPrefix = string_rep("  ", indent)

	local line = format("%s%s %s", indentPrefix, icon, label)
	bdd.report(line)
end

function bdd.reportFailingSubsection(label)
	local icon = brightRed("✗")

	local indent = bdd.reportIndentationLevel
	local indentPrefix = string_rep("  ", indent)

	local line = format("%s%s %s", indentPrefix, icon, brightRed(label))
	bdd.report(line)
end

function bdd.reset()
	bdd.lastExecutedSpecFile = nil

	bdd.numCompletedTests = 0
	bdd.numFailedTests = 0

	bdd.startTime = 0
	bdd.endTime = 0

	bdd.reportBuffer:reset()

	bdd.errorDetails = {}
end

function bdd.getSectionsReportString()
	local durationInMilliseconds = (bdd.endTime - bdd.startTime) / NANOSECONDS_PER_MILLISECOND
	durationInMilliseconds = math.floor(durationInMilliseconds + 0.5)

	local reportString = "\n"

	if bdd.numFailedTests == 0 and bdd.numCompletedTests == 0 then
		reportString = reportString .. transform.yellow("No tests to run ...")
	elseif bdd.numFailedTests > 1 then
		reportString = reportString
			.. format(
				transform.brightRedBackground("✗ %s tests FAILED (%s ms)"),
				bdd.numFailedTests,
				durationInMilliseconds
			)
	elseif bdd.numFailedTests == 1 then
		reportString = reportString
			.. format(
				transform.brightRedBackground("✗ %s test FAILED (%s ms)"),
				bdd.numFailedTests,
				durationInMilliseconds
			)
	elseif bdd.numCompletedTests > 1 then
		reportString = reportString
			.. format(transform.green("✓ %s tests complete (%s ms)"), bdd.numCompletedTests, durationInMilliseconds)
	else
		reportString = reportString
			.. format(transform.green("✓ %s test complete (%s ms)"), bdd.numCompletedTests, durationInMilliseconds)
	end

	return reportString
end

function bdd.before(setupFunction)
	validateFunction(setupFunction, "setupFunction")
	table_insert(bdd.registeredSetupFunctions, setupFunction)
end

function bdd.after(teardownFunction)
	validateFunction(teardownFunction, "teardownFunction")
	table_insert(bdd.registeredTeardownFunctions, teardownFunction)
end

bdd.describe = bdd.startSection
bdd.it = bdd.startSubsection

return bdd
