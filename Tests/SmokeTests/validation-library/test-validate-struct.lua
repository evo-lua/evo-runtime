local ffi = require("ffi")
local validation = require("validation")
local validateStruct = validation.validateStruct

local function testStructValueCase()
	local struct = ffi.new("int")
	assertDoesNotThrow(function()
		validateStruct(struct, "struct")
	end)
end

local function testStringValueCase()
	local str = "hello"
	assertThrows(function()
		validateStruct(str, "str")
	end, "Expected argument str to be a cdata value, but received a string value instead")
end

local function testNumberValueCase()
	local num = 5
	assertThrows(function()
		validateStruct(num, "num")
	end, "Expected argument num to be a cdata value, but received a number value instead")
end

local function testNilValueCase()
	local nilValue = nil
	assertThrows(function()
		validateStruct(nilValue, "nilValue")
	end, "Expected argument nilValue to be a cdata value, but received a nil value instead")
end

local function testValidateStruct()
	testStructValueCase()
	testStringValueCase()
	testNumberValueCase()
	testNilValueCase()
end

testValidateStruct()

print("OK", "validation", "validateStruct")
