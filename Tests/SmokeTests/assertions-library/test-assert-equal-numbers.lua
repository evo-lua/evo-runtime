local assertions = require("assertions")
local assertEqualNumbers = assertions.assertEqualNumbers
local assertApproximatelyEquals = assertions.assertApproximatelyEquals

local num1 = 1
local num2 = 1
local num3 = 2
local num4 = 0
local num5 = 1.0001
local num6 = 1.0002

local function testEqualNumbersCase()
	assert(assertEqualNumbers(num1, num2) == true, "assertEqualNumbers(num1, num2) should return true")
	local success, errorMessage = pcall(assertEqualNumbers, num1, num3)
	assert(success == false, "assertEqualNumbers(num1, num3) should raise an error")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected 2 but got 1$"),
		"assertEqualNumbers(num1, num3) should raise an error with the correct message"
	)
end

local function testAlmostEqualFloatsWithoutDeltaCase()
	local success, errorMessage = pcall(assertEqualNumbers, num5, num6)
	assert(success == false, "assertEqualNumbers(num5, num6) should raise an error")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected 1.0002 but got 1.0001$"),
		"assertEqualNumbers(num5, num6) should raise an error with the correct message"
	)
end

local function testEqualFloatsWithinDeltaCase()
	assert(assertEqualNumbers(num5, num6, 0.001) == true, "assertEqualNumbers(num5, num6, 0.001) should return true")
end

local function testEqualFloatsOutsideDeltaCase()
	local success, errorMessage = pcall(assertEqualNumbers, num5, num6, 0.00001)
	assert(success == false, "assertEqualNumbers(num5, num6, 0.00001) should raise an error")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected 1.0002 but got 1.0001 within delta 1e%-05$"),
		"assertEqualNumbers(num5, num6, 0.00001) should raise an error with the correct message"
	)
end

local function testAlmostEqualFloatsWithZeroDeltaCase()
	local success, errorMessage = pcall(assertEqualNumbers, num5, num6, 0)
	assert(success == false, "assertEqualNumbers(num5, num6, 0) should raise an error")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected 1.0002 but got 1.0001 within delta 0$"),
		"assertEqualNumbers(num5, num6, 0) should raise an error with the correct message"
	)
end

local function testDifferentNumbersCase()
	local success, errorMessage = pcall(assertEqualNumbers, num1, num4)
	assert(success == false, "assertEqualNumbers(num1, num4) should raise an error")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected 0 but got 1$"),
		"assertEqualNumbers(num1, num4) should raise an error with the correct message"
	)
end

local function testNumberAndStringCase()
	local success, errorMessage = pcall(assertEqualNumbers, num1, tostring(num1))
	assert(success == false, "assertEqualNumbers(num1, tostring(num1) should raise an error")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected numbers but got number and string$"),
		"assertEqualNumbers(num1, 'string') should raise an error with the correct message"
	)
end

local function testAlmostEqualNumbersCase()
	local success, errorMessage = pcall(assertEqualNumbers, num1, num2 + 0.1)
	assert(success == false, "assertEqualNumbers(num1, num2 + 0.1) should raise an error")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected 1.1 but got 1$"),
		"assertEqualNumbers(num1, num2 + 0.1) should raise an error with the correct message"
	)
end

local function testApproximatelyEqualsSuccessCase()
	assert(assertApproximatelyEquals(num1, num5) == true, "assertApproximatelyEquals(num1, num6) should return true")
end

local function testApproximatelyEqualsFailureCase()
	local success, errorMessage = pcall(assertApproximatelyEquals, 1.01, 1.02)
	assert(success == false, "assertApproximatelyEquals(1.01, 1.02) should raise an error")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected 1.02 but got 1.01 within delta 0.001$"),
		"assertApproximatelyEquals(num5, num6) should raise an error with the correct message"
	)
end

local function testAssertEqualNumbers()
	testEqualNumbersCase()
	testAlmostEqualFloatsWithoutDeltaCase()
	testEqualFloatsWithinDeltaCase()
	testEqualFloatsOutsideDeltaCase()
	testAlmostEqualFloatsWithZeroDeltaCase()
	testDifferentNumbersCase()
	testNumberAndStringCase()
	testAlmostEqualNumbersCase()
	testApproximatelyEqualsSuccessCase()
	testApproximatelyEqualsFailureCase()
end

testAssertEqualNumbers()

print("OK", "assertions", "assertEqualNumbers")
