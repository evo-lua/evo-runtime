local assertions = require("assertions")
local assertFailure = assertions.assertFailure

local function testFunctionReturnsFailureCase()
	local function functionThatReturnsFailure()
		return nil, "some error message"
	end

	local success = pcall(assertFailure, functionThatReturnsFailure)
	assert(success, "assertFailure should return true if the code under test returns a failure type")
end

local function testFunctionDoesNotReturnNilCase()
	local success, errorMessage = pcall(assertFailure, function()
		return "not nil", "error message"
	end)
	assert(not success, "Expected assertFailure to raise an error but it did not")
	assert(
		string.match(errorMessage, "ASSERTION FAILURE: Expected a failure but got success with value error message")
			~= nil,
		"Error message not as expected"
	)
end

local function testFunctionReturnsUnexpectedFailureMessageCase()
	local function functionThatReturnsUnexpectedFailureMessage()
		return nil, "meep"
	end
	local success, errorMessage = pcall(assertFailure, functionThatReturnsUnexpectedFailureMessage, "something else")
	assert(not success, "Expected assertFailure to raise an error but it did not")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected failure message 'something else' but got 'meep'$")
			~= nil,
		"Error message not as expected"
	)
end

local function testFunctionThrowsInsteadOfReturningFailureCase()
	local function functionThatThrows()
		error("error message", 0)
	end
	local success, errorMessage = pcall(assertFailure, functionThatThrows)
	assert(not success, "Expected assertFailure to raise an error but it did not")
	assert(
		string.match(errorMessage, "ASSERTION FAILURE: Expected a failure but got an error") ~= nil,
		"Error message not as expected"
	)
end

local function testAssertFailure()
	testFunctionReturnsFailureCase()
	testFunctionDoesNotReturnNilCase()
	testFunctionReturnsUnexpectedFailureMessageCase()
	testFunctionThrowsInsteadOfReturningFailureCase()
end

testAssertFailure()

print("OK", "assertions", "assertFailure")
