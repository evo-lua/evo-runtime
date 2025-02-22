local assertions = require("assertions")
local bdd = require("bdd")
local transform = require("transform")

local format = string.format

local bold = transform.bold
local brightRed = transform.brightRed
local green = transform.green
local yellow = transform.yellow

local startTestRunner = bdd.startTestRunner

package.open(assertions)

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
	assertEquals(numFailingTests, 4)
	local icon = brightRed("✗")
	local lines = {
		bold("top-level describe blocks"),
		"  " .. icon .. " " .. brightRed("should work"),
		"  " .. bold("nested describe blocks"),
		"    " .. icon .. " " .. brightRed("should also work"),
		icon .. " " .. brightRed("should even support standalone it blocks (questionable)"),
		icon .. " " .. brightRed("should translate builtin functions to human-readable names in error reports"),
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

	assertEquals(errorDetails[4].specFile, "Tests/Fixtures/failing-sections.spec.lua")
	assertEquals(errorDetails[4].message, "This reference should be resolved to 'function: tostring'")
	assertEquals(type(errorDetails[4].stackTrace), "string")
end

local function testSetupTeardownHookNestingCase()
	_G.CALLSTACK = {} -- Yeah, yeah...

	bdd.startTestRunner({ "Tests/Fixtures/before-after.spec.lua" })

	local expectedCallStack = {
		"start main chunk",
		"continue main chunk",
		"start section 1",
		"setup subsection (section 1)",
		"start subsection 1.1 (section 1)",
		"teardown subsection (section 1)",
		"setup subsection (section 1)",
		"start subsection 1.2 (section 1)",
		"teardown subsection (section 1)",
		"continue section 1",
		"start section 2 (section 1)",
		"continue section 2 (section 1)",
		"setup subsection (section 2)",
		"start subsection 2.1 (section 2)",
		"teardown subsection (section 2)",
		"setup subsection (section 2)",
		"start subsection 2.1 (section 2)",
		"teardown subsection (section 2)",
		"end of section 2 reached (section 1)",
		"continue section 1",
		"start section 3 (section 1)",
		"start section 4",
		"start subsection 3.1 (section 3)",
		"start subsection 3.2 (section 3)",
		"end of section 3 reached (section 1)",
		"end of section 1 reached",
		"continue with main chunk",
		"start section 5",
		"start subsection 5.1 (section 5)",
		"EOF reached in main chunk",
	}

	for index, event in ipairs(expectedCallStack) do
		local status = (event == _G.CALLSTACK[index]) and "OK" or "FAIL"
		print(format("%s\t%s\tExpected: %s -- Found: %s", status, index, event, _G.CALLSTACK[index]))
	end

	assertEquals(#_G.CALLSTACK, #expectedCallStack)

	assertEquals(_G.CALLSTACK[1], expectedCallStack[1])
	assertEquals(_G.CALLSTACK[2], expectedCallStack[2])
	assertEquals(_G.CALLSTACK[3], expectedCallStack[3])
	assertEquals(_G.CALLSTACK[4], expectedCallStack[4])
	assertEquals(_G.CALLSTACK[5], expectedCallStack[5])
	assertEquals(_G.CALLSTACK[6], expectedCallStack[6])
	assertEquals(_G.CALLSTACK[7], expectedCallStack[7])
	assertEquals(_G.CALLSTACK[8], expectedCallStack[8])
	assertEquals(_G.CALLSTACK[9], expectedCallStack[9])
	assertEquals(_G.CALLSTACK[10], expectedCallStack[10])
	assertEquals(_G.CALLSTACK[11], expectedCallStack[11])
	assertEquals(_G.CALLSTACK[12], expectedCallStack[12])
	assertEquals(_G.CALLSTACK[13], expectedCallStack[13])
	assertEquals(_G.CALLSTACK[14], expectedCallStack[14])
	assertEquals(_G.CALLSTACK[15], expectedCallStack[15])
	assertEquals(_G.CALLSTACK[16], expectedCallStack[16])
	assertEquals(_G.CALLSTACK[17], expectedCallStack[17])
	assertEquals(_G.CALLSTACK[18], expectedCallStack[18])
	assertEquals(_G.CALLSTACK[19], expectedCallStack[19])
	assertEquals(_G.CALLSTACK[20], expectedCallStack[20])
	assertEquals(_G.CALLSTACK[21], expectedCallStack[21])
	assertEquals(_G.CALLSTACK[22], expectedCallStack[22])
	assertEquals(_G.CALLSTACK[23], expectedCallStack[23])
	assertEquals(_G.CALLSTACK[24], expectedCallStack[24])
	assertEquals(_G.CALLSTACK[25], expectedCallStack[25])
	assertEquals(_G.CALLSTACK[26], expectedCallStack[26])
	assertEquals(_G.CALLSTACK[27], expectedCallStack[27])
	assertEquals(_G.CALLSTACK[28], expectedCallStack[28])
	assertEquals(_G.CALLSTACK[29], expectedCallStack[29])
	assertEquals(_G.CALLSTACK[30], expectedCallStack[30])

	_G.CALLSTACK = nil -- Is it a crime if there aren't any witnesses?
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
	testSetupTeardownHookNestingCase()
end

testStartTestRunner()

print("OK", "bdd", "startTestRunner")
