local validation = require("validation")
local validateNumber = validation.validateNumber

local function testNumberValueCase()
	local num = 5
	assertDoesNotThrow(function()
		validateNumber(num, "num")
	end)
end

local function testStringValueCase()
	local str = "hello"
	assertThrows(function()
		validateNumber(str, "str")
	end, "Expected argument str to be a number value, but received a string value instead")
end

local function testNumericStringCase()
	local numericString = "5"
	assertThrows(function()
		validateNumber(numericString, "numericString")
	end, "Expected argument numericString to be a number value, but received a string value instead")
end

local function testValidateNumber()
	testNumberValueCase()
	testStringValueCase()
	testNumericStringCase()
end

testValidateNumber()

print("OK", "validation", "validateNumber")
