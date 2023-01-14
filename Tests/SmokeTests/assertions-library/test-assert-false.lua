local assertions = require("assertions")
local assertFalse = assertions.assertFalse

local function testFalseCase()
	assert(assertFalse(false), "assertFalse(false) should return true and not raise an error")
end

local function testTrueCase()
	local status, errorMessage = pcall(assertFalse, true)
	assert(status == false, "assertFalse(true) should raise an error")
	assert(
		errorMessage == "ASSERTION FAILURE: true should be false",
		"assertFalse(true) should throw with error [[ASSERTION FAILURE: true should be false]] and not [["
			.. tostring(errorMessage)
			.. "]]"
	)
end

local function testNilCase()
	local status, errorMessage = pcall(assertFalse, nil)
	assert(status == false, "assertFalse(nil) should raise an error")
	assert(
		errorMessage == "ASSERTION FAILURE: nil should be false",
		"assertFalse(nil) should throw with error [[ASSERTION FAILURE: nil should be false]] and not [["
			.. tostring(errorMessage)
			.. "]]"
	)
end

local function testZeroCase()
	local status, errorMessage = pcall(assertFalse, 0)
	assert(status == false, "assertFalse(0) should raise an error")
	assert(
		errorMessage == "ASSERTION FAILURE: 0 should be false",
		"assertFalse(0) should throw with error [[ASSERTION FAILURE: 0 should be false]] and not [["
			.. tostring(errorMessage)
			.. "]]"
	)
end

local function testAssertFalse()
	testFalseCase()
	testTrueCase()
	testNilCase()
	testZeroCase()
end

testAssertFalse()

print("OK", "assertions", "assertFalse")
