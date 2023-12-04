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
end)
