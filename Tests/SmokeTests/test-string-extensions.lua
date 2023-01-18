local transform = require("transform")
local diff = string.diff

local function testNilValuesCase()
	local success, errorMessage = pcall(diff, nil, nil)
	assertFalse(success)
	assertEquals(errorMessage, "Expected argument before to be a string value, but received a nil value instead")
end

local function testEmptyStringsCase()
	local firstString = ""
	local secondString = ""
	local expectedDiff = ""

	local actualDiff = diff(firstString, secondString)
	assertEquals(actualDiff, expectedDiff)
end

local function testSingleLinesWithoutChangesCase()
	local firstString = "This line was not changed."
	local secondString = "This line was not changed."
	local expectedDiff = "  This line was not changed."

	local actualDiff = diff(firstString, secondString)
	assertEquals(actualDiff, expectedDiff)
end

local function testSingleLinesWithChangesCase()
	local firstString = "This line will be removed."
	local secondString = "This line will be added."
	local expectedDiff = transform.red("- This line will be removed.")
		.. "\n"
		.. transform.green("+ This line will be added.")

	local actualDiff = diff(firstString, secondString)
	assertEquals(actualDiff, expectedDiff)
end

local function testMultiLinesWithoutChangesCase()
	local firstString = "This line will be unchanged.\nThis line will be unchanged.\nThis line will be unchanged."
	local secondString = "This line will be unchanged.\nThis line will be unchanged.\nThis line will be unchanged."
	local expectedDiff = "  This line will be unchanged."
		.. "\n"
		.. "  This line will be unchanged."
		.. "\n"
		.. "  This line will be unchanged."

	local actualDiff = diff(firstString, secondString)
	assertEquals(actualDiff, expectedDiff)
end

local function testMultiLinesWithChangesCase()
	local firstString = "This line will be removed.\nThis line will be unchanged."
	local secondString = "This line will be added.\nThis line will be unchanged."
	local expectedDiff = transform.red("- This line will be removed.")
		.. "\n"
		.. transform.green("+ This line will be added.")
		.. "\n"
		.. "  ... (additional lines skipped)"

	local actualDiff = diff(firstString, secondString)
	assertEquals(actualDiff, expectedDiff)
end

local function testStringDiff()
	testNilValuesCase()
	testEmptyStringsCase()
	testSingleLinesWithoutChangesCase()
	testSingleLinesWithChangesCase()
	testMultiLinesWithoutChangesCase()
	testMultiLinesWithChangesCase()
end

testStringDiff()

print("OK", "string", "diff")
