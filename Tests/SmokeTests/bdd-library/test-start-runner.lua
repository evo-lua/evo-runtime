local bdd = require("bdd")
local transform = require("transform")

local format = string.format

local bold = transform.bold
local brightRed = transform.brightRed
local green = transform.green
local yellow = transform.yellow

local startTestRunner = bdd.startTestRunner

local function testNoFilesCase()
	local function runWithNil()
		bdd.startTestRunner(nil)
	end
	assertThrows(runWithNil, "Expected argument specFiles to be a table value, but received a nil value instead")
end

local function testInvalidFileCase()
	local function runWithInvalidFile()
		bdd.startTestRunner({ "does-not-exist.lua" })
	end
	assertThrows(runWithInvalidFile, "cannot open does-not-exist.lua: No such file or directory")

	-- Regression: The error message should always use the last requested spec file
	local function runWithAnotherInvalidFile()
		bdd.startTestRunner({ "does-not-exist-either.lua" })
	end
	assertThrows(runWithAnotherInvalidFile, "cannot open does-not-exist-either.lua: No such file or directory")
end

local function testOneFileCase()
	local function runWithSingleFile()
		bdd.startTestRunner("test.lua")
	end
	assertThrows(
		runWithSingleFile,
		"Expected argument specFiles to be a table value, but received a string value instead"
	)
end

local function testEmptyListCase()
	local function runWithoutTestCases()
		bdd.startTestRunner({})
	end
	assertThrows(runWithoutTestCases, "No test cases to run")
end

local function testNonStringEntriesCase()
	local function runWithInvalidSpecFileEntries()
		bdd.startTestRunner({ 42, print })
	end
	assertThrows(
		runWithInvalidSpecFileEntries,
		"Expected argument specFile to be a string value, but received a number value instead"
	)
end

local function testMinimalEmptyTestCase()
	bdd.setMinimalReportMode()

	local numFailingTests = startTestRunner({ "Tests/Fixtures/empty.spec.lua" })

	assertEquals(numFailingTests, 0)

	local reportString = bdd.getReport()
	local expectedReportString = ""
	assertEquals(reportString, expectedReportString)

	local errorDetails = bdd.getErrorDetails()
	assertEquals(#errorDetails, 0)
end

local function testMinimalPassingTestCase()
	bdd.setMinimalReportMode()

	local numFailingTests = startTestRunner({ "Tests/Fixtures/passing.spec.lua" })

	assertEquals(numFailingTests, 0)

	local reportString = bdd.getReport()
	local expectedReportString = ""
	assertEquals(reportString, expectedReportString)

	local errorDetails = bdd.getErrorDetails()
	assertEquals(#errorDetails, 0)
end

local function testMinimalFailingTestCase()
	bdd.setMinimalReportMode()

	local function runFailingTest()
		startTestRunner({ "Tests/Fixtures/failing.spec.lua" })
	end

	assertThrows(runFailingTest, "meep")

	local errorDetails = bdd.getErrorDetails()
	assertEquals(#errorDetails, 1)

	assertEquals(errorDetails[1].specFile, "Tests/Fixtures/failing.spec.lua")
	assertEquals(errorDetails[1].message, "meep")
	assertEquals(type(errorDetails[1].stackTrace), "string")
end

local function testBasicEmptyTestCase()
	bdd.setBasicReportMode()

	local numFailingTests = startTestRunner({ "Tests/Fixtures/empty.spec.lua" })

	assertEquals(numFailingTests, 0)

	local reportString = bdd.getReport()
	local expectedReportString = "Test runner started with a total of "
		.. bold("1")
		.. " spec file(s)"
		.. "\n\n"
		.. green("PASS\tTests/Fixtures/empty.spec.lua")
		.. "\n\n"
		.. "Finished running all tests in "
		.. bdd.getElapsedTime()
		.. "\n"
	assertEquals(reportString, expectedReportString)

	local errorDetails = bdd.getErrorDetails()
	assertEquals(#errorDetails, 0)
end

local function testBasicEmptyTestCases()
	bdd.setBasicReportMode()

	local numFailingTests = startTestRunner({ "Tests/Fixtures/empty.spec.lua", "Tests/Fixtures/empty.spec.lua" })

	assertEquals(numFailingTests, 0)

	local reportString = bdd.getReport()
	local expectedReportString = "Test runner started with a total of "
		.. bold("2")
		.. " spec file(s)"
		.. "\n\n"
		.. green("PASS\tTests/Fixtures/empty.spec.lua")
		.. "\n"
		.. green("PASS\tTests/Fixtures/empty.spec.lua")
		.. "\n\n"
		.. "Finished running all tests in "
		.. bdd.getElapsedTime()
		.. "\n"
	assertEquals(reportString, expectedReportString)

	local errorDetails = bdd.getErrorDetails()
	assertEquals(#errorDetails, 0)
end

local function testBasicPassingTestCase()
	bdd.setBasicReportMode()

	local numFailingTests = startTestRunner({ "Tests/Fixtures/passing.spec.lua" })

	assertEquals(numFailingTests, 0)

	local reportString = bdd.getReport()
	local expectedReportString = "Test runner started with a total of "
		.. bold("1")
		.. " spec file(s)"
		.. "\n\n"
		.. green("PASS\tTests/Fixtures/passing.spec.lua")
		.. "\n\n"
		.. "Finished running all tests in "
		.. bdd.getElapsedTime()
		.. "\n"

	assertEquals(reportString, expectedReportString)

	local errorDetails = bdd.getErrorDetails()
	assertEquals(#errorDetails, 0)
end

local function testBasicFailingTestCase()
	bdd.setBasicReportMode()

	local numFailingTests = startTestRunner({ "Tests/Fixtures/failing.spec.lua" })

	assertEquals(numFailingTests, 1)

	local reportString = bdd.getReport()
	local expectedReportString = "Test runner started with a total of "
		.. bold("1")
		.. " spec file(s)"
		.. "\n\n"
		.. brightRed("FAIL\tTests/Fixtures/failing.spec.lua")
		.. "\n\n"
		.. "Finished running all tests in "
		.. bdd.getElapsedTime()
		.. "\n"

	assertEquals(reportString, expectedReportString)

	local errorDetails = bdd.getErrorDetails()
	assertEquals(#errorDetails, numFailingTests)

	assertEquals(errorDetails[1].specFile, "Tests/Fixtures/failing.spec.lua")
	assertEquals(errorDetails[1].message, "meep")
	assertEquals(type(errorDetails[1].stackTrace), "string")
end

local function testDetailedEmptyTestCase()
	bdd.setDetailedReportMode()

	local numFailingTests = startTestRunner({ "Tests/Fixtures/empty.spec.lua" })

	assertEquals(numFailingTests, 0)

	local reportString = bdd.getReport()
	local expectedReportString = "\n" .. yellow("No tests to run ...") .. "\n"
	assertEquals(reportString, expectedReportString)

	local errorDetails = bdd.getErrorDetails()
	assertEquals(#errorDetails, 0)
end

local function testDetailedPassingTestCase()
	bdd.setDetailedReportMode()

	local numFailingTests = startTestRunner({ "Tests/Fixtures/passing.spec.lua" })

	assertEquals(numFailingTests, 0)

	local icon = green("✓")
	local lines = {
		bold("top-level describe blocks"),
		format("  %s should work", icon),
		"  " .. bold("nested describe blocks"),
		format("    %s should also work", icon),
		format("%s should even support standalone it blocks (questionable)", icon),
		bdd.getSectionsReportString(),
		"",
	}
	local reportString = bdd.getReport()
	local expectedReportString = table.concat(lines, "\n")
	assertEquals(reportString, expectedReportString)

	local errorDetails = bdd.getErrorDetails()
	assertEquals(#errorDetails, 0)
end

local function testDetailedFailingTestCase()
	bdd.setDetailedReportMode()

	local function runFailingTest()
		startTestRunner({ "Tests/Fixtures/failing.spec.lua" })
	end

	assertThrows(runFailingTest, "meep")

	local errorDetails = bdd.getErrorDetails()
	assertEquals(#errorDetails, 1)

	assertEquals(errorDetails[1].specFile, "Tests/Fixtures/failing.spec.lua")
	assertEquals(errorDetails[1].message, "meep")
	assertEquals(type(errorDetails[1].stackTrace), "string")
end

local function testDetailedFailingSectionsCase()
	bdd.setDetailedReportMode()

	local numFailingTests = startTestRunner({ "Tests/Fixtures/failing-sections.spec.lua" })
	assertEquals(numFailingTests, 3)
	local icon = brightRed("✗")
	local lines = {
		bold("top-level describe blocks"),
		"  " .. icon .. " " .. brightRed("should work"),
		"  " .. bold("nested describe blocks"),
		"    " .. icon .. " " .. brightRed("should also work"),
		icon .. " " .. brightRed("should even support standalone it blocks (questionable)"),
		bdd.getSectionsReportString(),
		"",
	}
	local reportString = bdd.getReport()
	local expectedReportString = table.concat(lines, "\n")
	assertEquals(reportString, expectedReportString)

	local errorDetails = bdd.getErrorDetails()
	assertEquals(#errorDetails, numFailingTests)

	assertEquals(errorDetails[1].specFile, "Tests/Fixtures/failing-sections.spec.lua")
	assertEquals(errorDetails[1].message, "meep")
	assertEquals(type(errorDetails[1].stackTrace), "string")

	assertEquals(errorDetails[2].specFile, "Tests/Fixtures/failing-sections.spec.lua")
	assertEquals(errorDetails[2].message, "meep")
	assertEquals(type(errorDetails[2].stackTrace), "string")

	assertEquals(errorDetails[3].specFile, "Tests/Fixtures/failing-sections.spec.lua")
	assertEquals(errorDetails[3].message, "meep")
	assertEquals(type(errorDetails[3].stackTrace), "string")
end

local function testStartTestRunner()
	testNoFilesCase()
	testInvalidFileCase()
	testOneFileCase()
	testEmptyListCase()
	testNonStringEntriesCase()
	testMinimalEmptyTestCase()
	testMinimalPassingTestCase()
	testMinimalFailingTestCase()
	testDetailedFailingSectionsCase()
	testBasicEmptyTestCase()
	testBasicEmptyTestCases()
	testBasicPassingTestCase()
	testBasicFailingTestCase()
	testDetailedEmptyTestCase()
	testDetailedPassingTestCase()
	testDetailedFailingTestCase()
end

testStartTestRunner()

print("OK", "bdd", "startTestRunner")
