local table_contains = table.contains

describe("table", function()
	describe("contains", function()
		it("should throw if a non-table value was passed as the first parameter", function()
			local function containsNonTable()
				table_contains(nil, 42)
			end
			assertThrows(
				containsNonTable,
				"Expected argument table to be a table value, but received a nil value instead"
			)
		end)

		it("should return false if a nil value was passed as the second parameter", function()
			local result = table_contains({}, nil)
			assertFalse(result)
		end)

		it("should return false if the table doesn't contain the given value", function()
			local table = { 1, 2, 3 }
			local value = 4
			local result = table_contains(table, value)
			assertFalse(result)
		end)

		it("should return true if the table contains the given value", function()
			local table = { 1, 2, 3 }
			local value = 2
			local result = table_contains(table, value)
			assertTrue(result)
		end)
	end)

	describe("count", function()
		it("should return zero for empty tables", function()
			assertEquals(table.count({}), 0)
		end)

		it("should return the number of array elements if the hash part is empty", function()
			assertEquals(table.count({ "Hello", "world", 42, 12345 }), 4)
		end)

		it("should return the number of hash map entries if the array part is empty", function()
			assertEquals(table.count({ Hello = 42, world = 123 }), 2)
		end)

		it("should return the total sum of hash map and array entries if neither part is empty", function()
			assertEquals(table.count({ "Hello world", Hello = 42 }), 2)
		end)

		it("should skip nils in the array part if the hash map part is empty", function()
			assertEquals(table.count({ 1, nil, 2, nil, 3 }), 3)
		end)

		it("should skip nils in the hash map part if the array part is empty", function()
			assertEquals(table.count({ hi = 42, nil, test = 43, nil, meep = 44 }), 3)
		end)

		it("should skip nils in tables that have both an array and a hash map part", function()
			assertEquals(table.count({ hi = 42, nil, 43, nil, meep = 44 }), 3)
		end)
	end)

	describe("copy", function()
		it("should create a deep copy if the given table contains another table", function()
			local tableWithNestedSubtables = {
				subtable = { 42 },
				12345,
			}
			local deepCopy = table.copy(tableWithNestedSubtables)
			local expectedResult = {
				subtable = { 42 },
				12345,
			}

			assertEquals(#deepCopy, #expectedResult)
			assertEquals(table.count(deepCopy), table.count(expectedResult))
			assertEquals(deepCopy[1], expectedResult[1])
			assertEquals(deepCopy.subtable[1], expectedResult.subtable[1])
			assert(deepCopy.subtable ~= expectedResult.subtable, "Both tables should not be identical")
		end)
	end)

	describe("scopy", function()
		it("should create a shallow copy if the given table contains another table", function()
			local tableWithNestedSubtables = {
				subtable = { 42 },
				12345,
			}
			local shallowCopy = table.scopy(tableWithNestedSubtables)
			local expectedResult = {
				subtable = tableWithNestedSubtables.subtable,
				12345,
			}

			assertEquals(#shallowCopy, #expectedResult)
			assertEquals(table.count(shallowCopy), table.count(expectedResult))
			assertEquals(shallowCopy[1], expectedResult[1])
			assertEquals(shallowCopy.subtable[1], expectedResult.subtable[1])
			assert(shallowCopy.subtable == expectedResult.subtable, "Both tables should be identical")
		end)
	end)

	describe("new", function()
		it("should be available without having to require the LuaJIT extension manually", function()
			assertEquals(table.new, require("table.new"))
		end)
	end)

	describe("clear", function()
		it("should be available without having to require the LuaJIT extension manually", function()
			assertEquals(table.clear, require("table.clear"))
		end)
	end)

	describe("reverse", function()
		it("should throw if a non-table value was passed", function()
			assertThrows(function()
				table.reverse(42)
			end, "Expected argument tableToReverse to be a table value, but received a number value instead")
		end)

		it("should return a copy of the table with all array elements reversed", function()
			local input = { "A", "B", "C" }
			local expectedOutput = { "C", "B", "A" }
			assertEquals(table.reverse(input), expectedOutput)
		end)

		it("should return an empty table if only the dictionary part of the table was used", function()
			local input = { A = "A", B = "B", C = "C" }
			local expectedOutput = {}
			assertEquals(table.reverse(input), expectedOutput)
		end)

		it("should ignore all dictionary entries if the table is mixed", function()
			local input = { "A", "B", "C", Hello = "world", something = print }
			local expectedOutput = { "C", "B", "A" }
			assertEquals(table.reverse(input), expectedOutput)
		end)
	end)

	describe("invert", function()
		it("should throw if a non-table value was passed", function()
			assertThrows(function()
				table.invert(42)
			end, "Expected argument tableToInvert to be a table value, but received a number value instead")
		end)

		it("should return a copy of the table with the keys and values swapped", function()
			local input = { "A", "B", "C" }
			local expectedOutput = { A = 1, B = 2, C = 3 }
			assertEquals(table.invert(input), expectedOutput)
		end)
	end)

	describe("keys", function()
		it("should throw if a non-table value was passed as the first parameter", function()
			assertThrows(function()
				table.keys(nil)
			end, "Expected argument table to be a table value, but received a nil value instead")
		end)

		it("should return a list of keys for both the array and the dictionary part of the given table", function()
			local someTable = {
				A = 42,
				B = 123,
				"Hello",
				"world",
			}
			local keys = table.keys(someTable)
			assertTrue(table.contains(keys, 1))
			assertTrue(table.contains(keys, 2))
			assertTrue(table.contains(keys, "A"))
			assertTrue(table.contains(keys, "B"))
		end)
	end)

	describe("values", function()
		it("should throw if a non-table value was passed as the first parameter", function()
			assertThrows(function()
				table.values(nil)
			end, "Expected argument table to be a table value, but received a nil value instead")
		end)

		it("should return a list of values for both the array and the dictionary part of the given table", function()
			local someTable = {
				A = 42,
				B = 123,
				"Hello",
				"world",
			}
			local values = table.values(someTable)
			assertTrue(table.contains(values, 42))
			assertTrue(table.contains(values, 123))
			assertTrue(table.contains(values, "Hello"))
			assertTrue(table.contains(values, "world"))
		end)
	end)
end)
