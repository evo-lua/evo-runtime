local assertions = require("assertions")
local assertEqualStrings = assertions.assertEqualStrings

-- Lua strings
local string1 = "hello"
local string2 = "hello"
local string3 = "world"
local string4 = ""

local function testEqualStringsCase()
	assert(assertEqualStrings(string1, string2), "Expected string1 and string2 to be equal")
end

local function testNonEqualStringsCase()
	local success, error = pcall(assertEqualStrings, string1, string3)
	assert(
		not success,
		"Expected assertEqualStrings(string1, string3) to raise an error but it returned " .. tostring(error)
	)
end

local function testEmptyStringCase()
	local success, error = pcall(assertEqualStrings, string1, string4)
	assert(
		not success,
		"Expected assertEqualStrings(string1, string4) to raise an error but it returned " .. tostring(error)
	)
end

-- String buffers
local ffi = require("ffi")
local buffer1 = ffi.new("char[?]", 6)
ffi.copy(buffer1, "hello\0", 6)

local buffer2 = ffi.new("char[?]", 6)
ffi.copy(buffer2, "hello\0", 6)

local buffer3 = ffi.new("char[?]", 6)
ffi.copy(buffer3, "world\0", 6)

local function testEqualStringBuffersCase()
	assert(assertEqualStrings(buffer1, buffer2), "Expected buffer1 and buffer2 to be equal")
end

local function testNonEqualStringBuffersCase()
	local success, error = pcall(assertEqualStrings, buffer1, buffer3)
	assert(
		not success,
		"Expected assertEqualStrings(buffer1, buffer3) to raise an error but it returned " .. tostring(error)
	)
end

local function testAssertEqualStrings()
	testEqualStringsCase()
	testNonEqualStringsCase()
	testEmptyStringCase()
	testEqualStringBuffersCase()
	testNonEqualStringBuffersCase()
end

testAssertEqualStrings()

print("OK", "assertions", "assertEqualStrings")
