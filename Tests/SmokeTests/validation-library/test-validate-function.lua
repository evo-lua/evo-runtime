local validation = require("validation")
local validateFunction = validation.validateFunction

local function testFunctionValueCase()
	local func = function() end
	assertDoesNotThrow(function()
		validateFunction(func, "func")
	end)
end

local function testStringValueCase()
	local str = "hello"
	assertThrows(function()
		validateFunction(str, "str")
	end, "Expected argument str to be a function value, but received a string value instead")
end

local function testNumberValueCase()
	local num = 5
	assertThrows(function()
		validateFunction(num, "num")
	end, "Expected argument num to be a function value, but received a number value instead")
end

local function testNilValueCase()
	local nilValue = nil
	assertThrows(function()
		validateFunction(nilValue, "nilValue")
	end, "Expected argument nilValue to be a function value, but received a nil value instead")
end

local function testValidateFunction()
	testFunctionValueCase()
	testStringValueCase()
	testNumberValueCase()
	testNilValueCase()
end

testValidateFunction()

print("OK", "validation", "validateFunction")
