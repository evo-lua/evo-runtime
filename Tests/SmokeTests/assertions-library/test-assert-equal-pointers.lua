local assertions = require("assertions")
local assertEqualPointers = assertions.assertEqualPointers

local ffi = require("ffi")

ffi.cdef([[
    typedef struct {
        int x;
        int y;
    } point;
]])

local point1 = ffi.new("point", { x = 1, y = 2 })
local point2 = ffi.new("point", { x = 1, y = 2 })
local point3 = ffi.new("point", { x = 2, y = 3 })

local function testSameStructsCase()
	assert(assertEqualPointers(point1, point1), "Expected assertEqualPointers(point1, point1) to be equal")
end

local function testClonedStructsCase()
	local success, errorMessage = pcall(assertEqualPointers, point1, point2)
	assert(
		not success,
		"Expected assertEqualPointers(point1, point2) to raise an error but it returned " .. tostring(errorMessage)
	)
	assert(
		string.match(
			errorMessage,
			"^ASSERTION FAILURE: Expected " .. tostring(point1) .. " but got " .. tostring(point2)
		),
		errorMessage
	)
end

local function testNonEqualPointersCase()
	local success, errorMessage = pcall(assertEqualPointers, point1, point3)
	assert(
		not success,
		"Expected assertEqualPointers(point1, point3) to raise an error but it returned " .. tostring(errorMessage)
	)
	assert(
		string.match(
			errorMessage,
			"^ASSERTION FAILURE: Expected " .. tostring(point1) .. " but got " .. tostring(point3)
		),
		errorMessage
	)
end

local function testAssertEqualPointers()
	testSameStructsCase()
	testClonedStructsCase()
	testNonEqualPointersCase()
end

testAssertEqualPointers()

print("OK", "assertions", "assertEqualPointers")
