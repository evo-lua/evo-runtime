local validation = require("validation")
local validateBoolean = validation.validateBoolean

local function testBooleanValueCase()
	local boolean = true
	assertDoesNotThrow(function()
		validateBoolean(boolean, "boolean")
	end)
end

local function testStringValueCase()
	local str = "hello"
	assertThrows(function()
		validateBoolean(str, "str")
	end, "Expected argument str to be a boolean value, but received a string value instead")
end

local function testNumberValueCase()
	local num = 5
	assertThrows(function()
		validateBoolean(num, "num")
	end, "Expected argument num to be a boolean value, but received a number value instead")
end

local function testNilValueCase()
	local nilValue = nil
	assertThrows(function()
		validateBoolean(nilValue, "nilValue")
	end, "Expected argument nilValue to be a boolean value, but received a nil value instead")
end

local function testValidateBoolean()
	testBooleanValueCase()
	testStringValueCase()
	testNumberValueCase()
	testNilValueCase()
end

testValidateBoolean()

print("OK", "validation", "validateBoolean")
