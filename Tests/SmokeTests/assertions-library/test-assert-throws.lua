local assertions = require("assertions")
local assertThrows = assertions.assertThrows

local function testExpectedErrorIsThrownCase()
	local expectedErrorMessage = "some error message"

	local function functionThatThrowsTheExpectedError()
		error(expectedErrorMessage, 0)
	end
	local status = pcall(assertThrows, functionThatThrowsTheExpectedError, expectedErrorMessage)

	assert(status == true, "assertThrows should not throw an error when the error message matches the expected message")
end

local function testNoErrorIsThrownCase()
	local NOOP_FUNCTION = function() end
	local status, errorMessage = pcall(assertThrows, NOOP_FUNCTION, "some error message")
	assert(status == false, "assertThrows should throw an error when the function doesn't throw an error")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Function did not raise an error$") ~= nil,
		"assertThrows should throw an error message with the proper format"
	)
end

local function testTheWrongErrorIsThrownCase()
	local functionThatThrowsAnUnexpectedError = function()
		error("unexpected error message", 0)
	end

	local status, errorMessage = pcall(assertThrows, functionThatThrowsAnUnexpectedError, "some error message")
	assert(
		status == false,
		"assertThrows should throw an error when the error message doesn't match the expected message"
	)
	assert(
		string.match(
			errorMessage,
			'^ASSERTION FAILURE: Thrown error "unexpected error message" should be "some error message"$'
		) ~= nil,
		"assertThrows should throw an error message with the proper format"
	)
end

local function testFunctionReturnsFailureInsteadOfThrowingCase()
	local functionThatReturnsFailure = function()
		return nil, "some failure message"
	end
	local status, errorMessage = pcall(assertThrows, functionThatReturnsFailure, "unexpected error message")
	assert(status == false, "assertThrows should throw an error when the function returns nil")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Function did not raise an error") ~= nil,
		"assertThrows should throw an error message with the proper format"
	)
end

local function testFunctionThrowsWithEmptyErrorMessageCase()
	local functionThatThrowsWithEmptyString = function()
		error("", 0)
	end
	local status, errorMessage = pcall(assertThrows, functionThatThrowsWithEmptyString, "unexpected error message")
	assert(status == false, "assertThrows should throw an error when the error message is empty")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Thrown error .* should be .*") ~= nil,
		"assertThrows should throw an error message with the proper format"
	)
end

local function testAssertThrows()
	testExpectedErrorIsThrownCase()
	testNoErrorIsThrownCase()
	testTheWrongErrorIsThrownCase()
	testFunctionReturnsFailureInsteadOfThrowingCase()
	testFunctionThrowsWithEmptyErrorMessageCase()
end

testAssertThrows()

print("OK", "assertions", "assertThrows")
