local buffer = require("string.buffer")
local ffi = require("ffi")
local validation = require("validation")
local validateString = validation.validateString

local function testStringValueCase()
	local str = "hello"
	assertDoesNotThrow(function()
		validateString(str, "str")
	end)
end

local function testNumberValueCase()
	local num = 5
	assertThrows(function()
		validateString(num, "num")
	end, "Expected argument num to be a string value, but received a number value instead")
end

local function testBooleanValueCase()
	local boolean = true
	assertThrows(function()
		validateString(boolean, "bool")
	end, "Expected argument bool to be a string value, but received a boolean value instead")
end

local function testCharBufferCase()
	local charBuffer = ffi.new("char[?]", 5)
	assertThrows(function()
		validateString(charBuffer, "charBuffer")
	end, "Expected argument charBuffer to be a string value, but received a cdata value instead")
end

local function testStringBufferCase()
	local stringBuffer = buffer.new()
	stringBuffer:put("hello")
	assertThrows(function()
		validateString(stringBuffer, "stringBuffer")
	end, "Expected argument stringBuffer to be a string value, but received a userdata value instead")
end

local function testStringBufferCoercedCase()
	local stringBuffer = buffer.new()
	stringBuffer:put("hello")
	validateString(tostring(stringBuffer), "stringBuffer")
end

local function testStructCase()
	local cdata = ffi.new("int")
	assertThrows(function()
		validation.validateString(cdata, "cdata")
	end, "Expected argument cdata to be a string value, but received a cdata value instead")
end

local function testValidateString()
	testStringValueCase()
	testNumberValueCase()
	testBooleanValueCase()
	testCharBufferCase()
	testStringBufferCase()
	testStringBufferCoercedCase()
	testStructCase()
end

testValidateString()

print("OK", "validation", "validateString")
