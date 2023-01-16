local validation = require("validation")
local validateThread = validation.validateThread

local function testThreadValueCase()
	local thread = coroutine.create(function() end)
	assertDoesNotThrow(function()
		validateThread(thread, "thread")
	end)
end

local function testStringValueCase()
	local str = "hello"
	assertThrows(function()
		validateThread(str, "str")
	end, "Expected argument str to be a thread value, but received a string value instead")
end

local function testNumberValueCase()
	local num = 5
	assertThrows(function()
		validateThread(num, "num")
	end, "Expected argument num to be a thread value, but received a number value instead")
end

local function testNilValueCase()
	local nilValue = nil
	assertThrows(function()
		validateThread(nilValue, "nilValue")
	end, "Expected argument nilValue to be a thread value, but received a nil value instead")
end

local function testValidateThread()
	testThreadValueCase()
	testStringValueCase()
	testNumberValueCase()
	testNilValueCase()
end

testValidateThread()

print("OK", "validation", "validateThread")
