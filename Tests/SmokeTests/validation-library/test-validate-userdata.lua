local buffer = require("string.buffer")
local validation = require("validation")
local validateUserdata = validation.validateUserdata

local function testUserdataValueCase()
	local userdata = buffer.new()
	assertDoesNotThrow(function()
		validateUserdata(userdata, "userdata")
	end)
end

local function testStringValueCase()
	local str = "hello"
	assertThrows(function()
		validateUserdata(str, "str")
	end, "Expected argument str to be a userdata value, but received a string value instead")
end

local function testNumberValueCase()
	local num = 5
	assertThrows(function()
		validateUserdata(num, "num")
	end, "Expected argument num to be a userdata value, but received a number value instead")
end

local function testNilValueCase()
	local nilValue = nil
	assertThrows(function()
		validateUserdata(nilValue, "nilValue")
	end, "Expected argument nilValue to be a userdata value, but received a nil value instead")
end

local function testValidateUserdata()
	testUserdataValueCase()
	testStringValueCase()
	testNumberValueCase()
	testNilValueCase()
end

testValidateUserdata()

print("OK", "validation", "validateUserdata")
