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
end)
