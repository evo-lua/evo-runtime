local assertions = require("assertions")
local assertEqualBooleans = assertions.assertEqualBooleans

local function testTrueCase()
	assert(assertEqualBooleans(true, true), "assertEqualBooleans(true, true) should return true and not throw")
end

local function testFalseCase()
	assert(assertEqualBooleans(false, false), "assertEqualBooleans(false, false) should return true and not throw")
end

local function testFalseNilCase()
	local success, errorMessage = assertEqualBooleans(false, nil)

	assert(not success, "assertEqualBooleans(false, nil) should return nil")
	assert(errorMessage == nil, "assertEqualBooleans(false, nil) should not throw")
end

local function testTrueFalseCase()
	local success, errorMessage = pcall(assertEqualBooleans, true, false)
	assert(not success, "assertEqualBooleans(true, false) should return nil")
	assert(
		errorMessage == "ASSERTION FAILURE: Expected false but got true",
		"assertEqualBooleans(true, false) should throw with the expected error message"
	)
end

local function testFalseTrueCase()
	local success, errorMessage = pcall(assertEqualBooleans, false, true)
	assert(not success, "assertEqualBooleans(false, true) should return nil")
	assert(
		errorMessage == "ASSERTION FAILURE: Expected true but got false",
		"assertEqualBooleans(false, true) should throw with the expected error message"
	)
end

local function testAssertEqualBooleans()
	testTrueCase()
	testFalseCase()
	testFalseNilCase()
	testFalseTrueCase()
	testTrueFalseCase()
end

testAssertEqualBooleans()

print("OK", "assertions", "assertEqualBooleans")
