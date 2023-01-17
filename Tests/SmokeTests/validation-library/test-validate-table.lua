local validation = require("validation")
local validateTable = validation.validateTable

local function testTableValueCase()
	local tableValue = { 1, 2, 3 }
	assertDoesNotThrow(function()
		validateTable(tableValue, "tableValue")
	end)
end

local function testStringValueCase()
	local str = "hello"
	assertThrows(function()
		validateTable(str, "str")
	end, "Expected argument str to be a table value, but received a string value instead")
end

local function testNumberValueCase()
	local num = 5
	assertThrows(function()
		validateTable(num, "num")
	end, "Expected argument num to be a table value, but received a number value instead")
end

local function testNilValueCase()
	local nilValue = nil
	assertThrows(function()
		validateTable(nilValue, "nilValue")
	end, "Expected argument nilValue to be a table value, but received a nil value instead")
end

local function testValidateTable()
	testTableValueCase()
	testStringValueCase()
	testNumberValueCase()
	testNilValueCase()
end

testValidateTable()

print("OK", "validation", "validateTable")
