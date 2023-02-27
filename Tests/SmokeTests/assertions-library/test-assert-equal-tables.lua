local assertions = require("assertions")
local assertEqualTables = assertions.assertEqualTables

-- Flat tables
local table1 = { x = 1, y = 2 }
local table2 = { x = 1, y = 2 }
local table3 = { x = 2, y = 3 }
local table4 = { x = 1, y = 2, z = 3 }

local function testFlatTablesEqualCase()
	local success, errorMessage = pcall(assertEqualTables, table1, table2)
	assert(success, "assertEqualTables should return true when both tables are flat and equal")
	assert(errorMessage == nil, "assertEqualTables should not throw when both tables are flat and equal")
end

local function testFlatTablesNotEqualCase()
	local success, errorMessage = pcall(assertEqualTables, table1, table3)
	assert(not success, "Expected assertEqualTables to raise an error but it did not")
	assert(
		string.match(errorMessage, "ASSERTION FAILURE: Expected .* but got .*") ~= nil,
		"Error message not as expected: \n" .. errorMessage
	)
end

local function testFlatTablesWithDifferentLengthCase()
	local success, errorMessage = pcall(assertEqualTables, table1, table4)
	assert(not success, "Expected assertEqualTables to raise an error but it did not")
	assert(
		string.match(errorMessage, "ASSERTION FAILURE: Expected .* but got .*") ~= nil,
		"Error message not as expected: \n" .. errorMessage
	)
end

-- Nested tables
table1 = { x = 1, y = 2, subtable = { a = 1, b = 2 } }
table2 = { x = 1, y = 2, subtable = { a = 1, b = 2 } }
table3 = { x = 1, y = 2, subtable = { a = 1, b = 3, c = { 42 } } }
table4 = { x = 1, y = 2, subtable = { a = 1, b = 3, c = { 42 } } }

local function testNestedTablesEqualCase()
	local success, errorMessage = pcall(assertEqualTables, table3, table4)
	assert(success, "assertEqualTables should return true when both tables are nested and equal")
	assert(errorMessage == nil, "assertEqualTables should not throw when both tables are nested and equal")
end

local function testNestedTablesNotEqualCase()
	local success, errorMessage = pcall(assertEqualTables, table1, table3) -- should raise an error
	assert(not success, "Expected assertEqualTables to raise an error but it did not")
	assert(
		string.match(errorMessage, "ASSERTION FAILURE: Expected .* but got .*") ~= nil,
		"Error message not as expected: \n" .. errorMessage
	)
end

local function testAssertEqualTables()
	testFlatTablesEqualCase()
	testFlatTablesNotEqualCase()
	testFlatTablesWithDifferentLengthCase()
	testNestedTablesEqualCase()
	testNestedTablesNotEqualCase()
end

testAssertEqualTables()

print("OK", "assertions", "assertEqualTables")
