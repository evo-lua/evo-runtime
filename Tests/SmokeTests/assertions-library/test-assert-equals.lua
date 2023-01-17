local assertions = require("assertions")
local assertEquals = assertions.assertEquals

local ffi = require("ffi")
local buffer = ffi.new("char[10]")
ffi.copy(buffer, "hello", #"hello")

dofile("Tests/SmokeTests/assertions-library/test-assert-equal-booleans.lua")
dofile("Tests/SmokeTests/assertions-library/test-assert-equal-numbers.lua")
dofile("Tests/SmokeTests/assertions-library/test-assert-equal-strings.lua")
dofile("Tests/SmokeTests/assertions-library/test-assert-equal-tables.lua")
dofile("Tests/SmokeTests/assertions-library/test-assert-equal-pointers.lua")
dofile("Tests/SmokeTests/assertions-library/test-assert-equal-bytes.lua")

local function testEqualNumbersCase()
	local status = pcall(assertEquals, 1, 1)
	assert(status == true, "assertEquals should not throw an error when the values match")
end

local function testDistinctNumbersCase()
	local status, errorMessage = pcall(assertEquals, 1, 2)
	assert(status == false, "assertEquals should throw an error when the values don't match")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected .* but got .*") ~= nil,
		"assertEquals should throw an error message with the proper format"
	)
end

local function testEqualStringsCase()
	local status = pcall(assertEquals, "hello", "hello")
	assert(status == true, "assertEquals should not throw an error when the values match")
end

local function testDistinctStringsCase()
	local status, errorMessage = pcall(assertEquals, "hello", "world")
	assert(status == false, "assertEquals should throw an error when the values don't match")
	assert(
		string.match(errorMessage, "ASSERTION FAILURE: Expected world but got hello") ~= nil,
		"assertEquals should throw an error message with the proper format"
	)
end

local function testEqualFlatTablesCase()
	local status = pcall(assertEquals, { a = 1, b = 2 }, { a = 1, b = 2 })
	assert(status == true, "assertEquals should not throw an error when the values match")

	status = pcall(assertEquals, { a = 1, b = 2 }, { b = 2, a = 1 })
	assert(status == true, "assertEquals should not throw an error when the tables match, regardless of order")
end

local function testDistinctFlatTablesCase()
	local status, errorMessage = pcall(assertEquals, { a = 1, b = 2, c = 3 }, { a = 1, b = 2 })
	assert(status == false, "assertEquals should throw an error when the tables do not match")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected .* but got .*") ~= nil,
		"assertEquals should throw an error message with the proper format"
	)
end

local function testEqualNestedTablesCase()
	local status = pcall(assertEquals, { a = 1, b = { c = 2 } }, { a = 1, b = { c = 2 } })
	assert(status == true, "assertEquals should not throw an error when the nested table values match")
end

local function testEqualStringBuffersCase()
	local sb1 = string.dump(function() end)
	local status = pcall(assertEquals, sb1, sb1)
	assert(status == true, "assertEquals should not throw an error when comparing equal stringbuffer values")

	local buf1 = string.rep("a", 100)
	local buf2 = string.rep("a", 100)
	status = pcall(assertEquals, buf1, buf2)
	assert(status == true, "assertEquals should not throw an error when the string buffer contents match")
end

local function testDistinctStringBuffersCase()
	local sb1, sb2 = string.dump(function() end), string.dump(function() end)
	sb2 = string.sub(sb2, 1, -2) .. "a"
	local status, errorMessage = pcall(assertEquals, sb1, sb2)
	assert(status == false, "assertEquals should throw an error when comparing different stringbuffer values")
	assert(
		string.match(errorMessage, "ASSERTION FAILURE: Expected .* but got .*") ~= nil,
		"assertEquals should throw an error message with the proper format"
	)
end

local function testNilAndNilCase()
	local status = pcall(assertEquals, nil, nil)
	assert(status == true, "assertEquals should not throw an error when the values match")
end

local function testNumberAndNilCase()
	local status, errorMessage = pcall(assertEquals, 1, nil)
	assert(status == false, "assertEquals should throw an error when the values don't match")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected .* but got .*") ~= nil,
		"assertEquals should throw an error message with the proper format"
	)
end

local function testDistinctStructsCase()
	local status, errorMessage = pcall(assertEquals, ffi.new("int[1]", 1), ffi.new("int[1]", 2))
	assert(status == false, "assertEquals should throw an error when comparing different cdata values")
	assert(
		string.match(errorMessage, "^ASSERTION FAILURE: Expected .* but got .*") ~= nil,
		"assertEquals should throw an error message with the proper format"
	)
end

local function testAssertEquals()
	testEqualNumbersCase()
	testDistinctNumbersCase()

	testEqualStringsCase()
	testDistinctStringsCase()

	testEqualFlatTablesCase()
	testDistinctFlatTablesCase()

	testEqualNestedTablesCase()

	testNilAndNilCase()
	testNumberAndNilCase()

	testEqualStringBuffersCase()
	testDistinctStringBuffersCase()

	testDistinctStructsCase()
end

testAssertEquals()

print("OK", "assertions", "assertEquals")
