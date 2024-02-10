local glfw = require("glfw")

describe("glfw", function()
	describe("bindings", function()
		it("should export the entirety of the glfw API", function()
			for _, functionName in ipairs(glfw.exports) do
				assertEquals(type(glfw.bindings[functionName]), "cdata")
			end
		end)
	end)

	describe("glfw_find_constant", function()
		it("should return the defined value if the constant exists", function()
			local value = glfw.find_constant("GLFW_KEY_0")
			assertEquals(value, 48)
		end)

		it("should return a special sentinel value if the constant does not exist", function()
			local value = glfw.find_constant("DOES_NOT_EXIST")
			assertEquals(value, 0xdead)
		end)
	end)

	describe("version", function()
		it("should return the embedded glfw version in semver format", function()
			local versionString = glfw.version()
			local firstMatchedCharacterIndex, lastMatchedCharacterIndex = string.find(versionString, "%d+.%d+.%d+")

			assertEquals(firstMatchedCharacterIndex, 1)
			assertEquals(lastMatchedCharacterIndex, string.len(versionString))
			assertEquals(type(string.match(versionString, "%d+.%d+.%d+")), "string")
		end)
	end)
end)
