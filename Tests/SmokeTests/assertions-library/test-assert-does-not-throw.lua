local assertions = require("assertions")
local assertDoesNotThrow = assertions.assertDoesNotThrow

local function testFunctionDoesNotThrowCase()
	local function NOOP_FUNCTION() end
	local success, returnValue = pcall(assertDoesNotThrow, NOOP_FUNCTION)
	assert(success, "assertDoesNotThrow should not raise an error when the function doesn't throw an error")
	assert(returnValue, "assertDoesNotThrow should return true when the function doesn't throw an error")
end

local function testFunctionThrowsCase()
	local status, errorMessage = pcall(assertDoesNotThrow, function()
		error("Test error", 0)
	end)
	assert(status == false, "assertDoesNotThrow should throw an error when the function throws an error")
	assert(
		string.match(errorMessage, "ASSERTION FAILURE: Expected function to not throw an error but it threw Test error"),
		errorMessage
	)
end

local function testAssertDoesNotThrow()
	testFunctionDoesNotThrowCase()
	testFunctionThrowsCase()
end

testAssertDoesNotThrow()

print("OK", "assertions", "assertDoesNotThrow")
