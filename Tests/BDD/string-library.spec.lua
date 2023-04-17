describe("string", function()
	describe("explode", function()
		it("should return an array of whitespace-delimited tokens if no delimiter was passed ", function()
			assertEquals(string.explode("hello world"), { "hello", "world" })
		end)

		it("should return an array of tokens if the given delimiter occurs in the input string", function()
			assertEquals(string.explode("hello_world", "_"), { "hello", "world" })
		end)

		it("should return the input string itself if the given delimiter doesn't occur in it", function()
			assertEquals(string.explode("hello#world", "_"), { "hello#world" })
		end)

		it("should raise an error if no input string was given", function()
			local expectedError = "Expected argument inputString to be a string value, but received a nil value instead"
			assertThrows(function()
				string.explode(nil)
			end, expectedError)
		end)

		it("should raise an error if a n invalid delimiter was given", function()
			local expectedError =
				"Expected argument delimiter to be a string value, but received a number value instead"
			assertThrows(function()
				string.explode("asdf", 42)
			end, expectedError)
		end)
	end)
end)
