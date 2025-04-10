local assertions = require("assertions")
local ffi = require("ffi")
local assertCallsFunction = assertions.assertCallsFunction

local function testFunctionCallsFunctionCase()
	local function NOOP_FUNCTION() end

	local function functionThatCallsTheExpectedFunction()
		NOOP_FUNCTION()
	end

	local success, errorMessage = pcall(assertCallsFunction, functionThatCallsTheExpectedFunction, NOOP_FUNCTION)
	assert(success, "assertCallsFunction should not throw if the expected function is called")
	assert(errorMessage == nil, "assertCallsFunction should not throw an error if the expected function is called")
end

local function testFunctionDoesNotCallAnyFunctionCase()
	local function NOOP_FUNCTION() end

	local success, errorMessage = pcall(assertCallsFunction, function() end, NOOP_FUNCTION)
	assert(not success, "assertCallsFunction should throw if no function is called")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected .* to be called but it was not$"),
		"assertCallsFunction should throw the expected error if no function is called"
	)
end

local function testFunctionDoesNotCallBuildinFunctionCase()
	local success, errorMessage = pcall(assertCallsFunction, function() end, ffi.gc)
	assert(not success, "assertCallsFunction should throw if the expected builtin is not called")
	assert(
		errorMessage == "ASSERTION FAILURE: Expected function: ffi.gc to be called but it was not",
		"assertCallsFunction should use human-readable names if a builtin was expected to be called"
	)
end

local function testFunctionCallsDifferentFunctionCase()
	local function NOOP_FUNCTION() end
	local function someOtherFunction()
		return 42
	end

	local function functionThatCallsSomeOtherFunction()
		someOtherFunction()
	end

	local success, errorMessage = pcall(assertCallsFunction, functionThatCallsSomeOtherFunction, NOOP_FUNCTION)
	assert(not success, "assertCallsFunction should throw if the expected function is not called")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected function: .* to be called but it was not$"),
		"assertCallsFunction should throw the expected error if the expected function is not called"
	)
end

local function testAssertCallsFunction()
	testFunctionCallsFunctionCase()
	testFunctionDoesNotCallAnyFunctionCase()
	testFunctionDoesNotCallBuildinFunctionCase()
	testFunctionCallsDifferentFunctionCase()
end

testAssertCallsFunction()

print("OK", "assertions", "assertCallsFunction")
