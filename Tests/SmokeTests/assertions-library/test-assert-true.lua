local assertions = require("assertions")
local assertTrue = assertions.assertTrue

local function testTrueCase()
	assert(assertTrue(true), "assertTrue(true) should return true and not raise an error")
end

local function testFalseCase()
	local status, errorMessage = pcall(assertTrue, false)
	assert(status == false, "assertTrue(false) should raise an error")
	assert(
		errorMessage == "ASSERTION FAILURE: false should be true",
		"assertTrue(false) should throw with error [[ASSERTION FAILURE: false should be true]] and not [["
			.. tostring(errorMessage)
			.. "]]"
	)
end

local function testNilCase()
	local status, errorMessage = pcall(assertTrue, nil)
	assert(status == false, "assertTrue(nil) should raise an error")
	assert(
		errorMessage == "ASSERTION FAILURE: nil should be true",
		"assertTrue(nil) should throw with error [[ASSERTION FAILURE: nil should be true]] and not [["
			.. tostring(errorMessage)
			.. "]]"
	)
end

local function testZeroCase()
	local status, errorMessage = pcall(assertTrue, 0)
	assert(status == false, "assertTrue(0) should raise an error")
	assert(
		errorMessage == "ASSERTION FAILURE: 0 should be true",
		"assertTrue(0) should throw with error [[ASSERTION FAILURE: 0 should be true]] and not [["
			.. tostring(errorMessage)
			.. "]]"
	)
end

local function testAssertTrue()
	testTrueCase()
	testFalseCase()
	testNilCase()
	testZeroCase()
end

testAssertTrue()

print("OK", "assertions", "assertTrue")
