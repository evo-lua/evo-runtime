local assertions = require("assertions")
local assertEqualFunctions = assertions.assertEqualFunctions

local function testEqualFunctionsCase()
	local success, returnValue = pcall(assertEqualFunctions, print, print)
	assert(success, "assertEqualFunctions(print, print) should not throw")
	assert(returnValue == true, "assertEqualFunctions(print, print) should return true")
end

local function testDifferentFunctionsCase()
	local success, errorMessage = pcall(assertEqualFunctions, print, tostring)
	local expectedErrorMessage = "^ASSERTION FAILURE: Expected "
		.. tostring(tostring)
		.. " but got "
		.. tostring(print)
		.. "$"

	assert(not success, "assertEqualFunctions(print, tostring) should throw")
	assert(
		string.match(errorMessage, expectedErrorMessage),
		"assertEqualFunctions(print, tostring) should throw the expected error"
	)
end

local function testFirstArgumentNotFunctionCase()
	local success, errorMessage = pcall(assertEqualFunctions, 42, tostring)
	local expectedErrorMessage = "^ASSERTION FAILURE: Expected two function values, got number and function$"

	assert(not success, "assertEqualFunctions(print, 42) should throw")
	assert(
		string.match(errorMessage, expectedErrorMessage),
		"assertEqualFunctions(print, 42) should throw the expected error"
	)
end

local function testSecondArgumentNotFunctionCase()
	local success, errorMessage = pcall(assertEqualFunctions, print, 42)
	local expectedErrorMessage = "^ASSERTION FAILURE: Expected two function values, got function and number$"

	assert(not success, "assertEqualFunctions(42, tostring) should throw")
	assert(
		string.match(errorMessage, expectedErrorMessage),
		"assertEqualFunctions(42, tostring) should throw the expected error"
	)
end

local function testBothArgumentsNotFunctionCase()
	local success, errorMessage = pcall(assertEqualFunctions, 42, 42)
	local expectedErrorMessage = "^ASSERTION FAILURE: Expected two function values, got number and number$"

	assert(not success, "assertEqualFunctions(42, 42) should throw")
	assert(
		string.match(errorMessage, expectedErrorMessage),
		"assertEqualFunctions(42, 42) should throw the expected error"
	)
end

local function testassertEqualFunctions()
	testEqualFunctionsCase()
	testDifferentFunctionsCase()
	testFirstArgumentNotFunctionCase()
	testSecondArgumentNotFunctionCase()
	testBothArgumentsNotFunctionCase()
end

testassertEqualFunctions()

print("OK", "assertions", "assertEqualFunctions")
