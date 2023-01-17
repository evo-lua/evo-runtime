local assertions = require("assertions")
local assertEqualBytes = assertions.assertEqualBytes

local ffi = require("ffi")

ffi.cdef([[
    typedef struct {
        int x;
        int y;
    } point;

	typedef struct {
		int a;
		int b;
	} totally_not_a_point;
]])

local point1 = ffi.new("point", { x = 1, y = 2 })
local point2 = ffi.new("point", { x = 1, y = 2 })
local point3 = ffi.new("point", { x = 2, y = 3 })
local notPoint = ffi.new("totally_not_a_point", { a = 1, b = 2 })

local function testSameStructsCase()
	assert(assertEqualBytes(point1, point1), "Expected assertEqualBytes(point1, point1) to be equal")
end

local function testClonedStructsCase()
	assert(assertEqualBytes(point1, point2), "Expected assertEqualBytes(point1, point2) to be equal")
end

local function testNonEqualPointersCase()
	local success, errorMessage = pcall(assertEqualBytes, point1, point3)
	assert(
		not success,
		"Expected assertEqualBytes(point1, point3) to raise an error but it returned " .. tostring(errorMessage)
	)
	assert(
		string.match(
			errorMessage,
			"^ASSERTION FAILURE: Expected " .. tostring(point3) .. " but got " .. tostring(point1)
		),
		errorMessage
	)
end

local function testFirstParameterIsLuaTypeCase()
	local success, errorMessage = pcall(assertEqualBytes, "huh?", point3)
	assert(not success, "assertEqualBytes should throw if a cdata parameter was passed alongside a  non-cdata one")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected two cdata values, got string and cdata$"),
		errorMessage
	)
end

local function testSecondParameterIsLuaTypeCase()
	local success, errorMessage = pcall(assertEqualBytes, point3, "meh")
	assert(not success, "assertEqualBytes should throw if a non-cdata parameter was passed alongside a cdata one")

	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected two cdata values, got cdata and string$"),
		errorMessage
	)
end

local function testBothParametersAreLuaTypesCase()
	local success, errorMessage = pcall(assertEqualBytes, "hello", "goodbye")
	assert(not success, "assertEqualBytes should throw if two non-cdata parameters were passed")

	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected two cdata values, got string and string$"),
		errorMessage
	)
end

local function testDifferentNativeTypesWithSameSizeCase()
	assert(
		assertEqualBytes(point1, notPoint),
		"assertEqualBytes should return true when two distinct byte-equal structs are passed"
	)
end

local function testAssertEqualBytes()
	testSameStructsCase()
	testClonedStructsCase()
	testNonEqualPointersCase()
	testFirstParameterIsLuaTypeCase()
	testSecondParameterIsLuaTypeCase()
	testBothParametersAreLuaTypesCase()
	testDifferentNativeTypesWithSameSizeCase()
end

testAssertEqualBytes()

print("OK", "assertions", "assertEqualBytes")
