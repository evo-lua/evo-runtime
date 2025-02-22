describe("top-level describe blocks", function()
	it("should work", function()
		error("meep", 0)
	end)
	describe("nested describe blocks", function()
		it("should also work", function()
			error("meep", 0)
		end)
		assertEquals(1, 1)
	end)
	assertEquals(1, 1)
end)
assertEquals(1, 1)

it("should even support standalone it blocks (questionable)", function()
	error("meep", 0)
end)

it("should translate builtin functions to human-readable names in error reports", function()
	local arbitraryBuiltinFunction = tostring
	-- Beware: Passing the function itself will be interpreted as an error object (no __tostring = glitched)
	local message = format("This reference should be resolved to '%s'", arbitraryBuiltinFunction)
	error(message, 0)
end)
