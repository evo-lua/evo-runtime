local assertions = require("assertions")
local assertNil = assertions.assertNil

local function testNilCase()
	assert(assertNil(nil), "assertNil(nil) should return true and not raise an error")
end

local function testTrueCase()
	local status, errorMessage = pcall(assertNil, true)
	assert(status == false, "assertNil(true) should raise an error")
	assert(
		errorMessage == "ASSERTION FAILURE: true should be nil",
		"assertNil(true) should throw with error [[ASSERTION FAILURE: true should be nil]] and not [["
			.. tostring(errorMessage)
			.. "]]"
	)
end

local function testFalseCase()
	local status, errorMessage = pcall(assertNil, false)
	assert(status == false, "assertNil(false) should raise an error")
	assert(
		errorMessage == "ASSERTION FAILURE: false should be nil",
		"assertNil(false) should throw with error [[ASSERTION FAILURE: false should be nil]] and not [["
			.. tostring(errorMessage)
			.. "]]"
	)
end

local function testZeroCase()
	local status, errorMessage = pcall(assertNil, 0)
	assert(status == false, "assertNil(0) should raise an error")
	assert(
		errorMessage == "ASSERTION FAILURE: 0 should be nil",
		"assertNil(0) should throw with error [[ASSERTION FAILURE: 0 should be nil]] and not [["
			.. tostring(errorMessage)
			.. "]]"
	)
end

local function testAssertNil()
	testNilCase()
	testTrueCase()
	testFalseCase()
	testZeroCase()
end

testAssertNil()

print("OK", "assertions", "assertNil")
