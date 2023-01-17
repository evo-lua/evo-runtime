local assertions = require("assertions")
local assertEqualNumbers = assertions.assertEqualNumbers

local num1 = 1
local num2 = 1
local num3 = 2
local num4 = 0

local function testEqualNumbersCase()
	assert(assertEqualNumbers(num1, num2) == true, "assertEqualNumbers(num1, num2) should return true")
	local success, errorMessage = pcall(assertEqualNumbers, num1, num3)
	assert(success == false, "assertEqualNumbers(num1, num3) should raise an error")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected 2 but got 1$"),
		"assertEqualNumbers(num1, num3) should raise an error with the correct message"
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

local function testAssertEqualNumbers()
	testEqualNumbersCase()
	testDifferentNumbersCase()
	testNumberAndStringCase()
	testAlmostEqualNumbersCase()
end

testAssertEqualNumbers()

print("OK", "assertions", "assertEqualNumbers")
