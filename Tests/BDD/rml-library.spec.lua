local rml = require("rml")

describe("rml", function()
	describe("version", function()
		it("should return the embedded RML version in semver format", function()
			local embeddedLibraryVersion = rml.version()
			local firstMatchedCharacterIndex, lastMatchedCharacterIndex =
				string.find(embeddedLibraryVersion, "%d+.%d+.%d+")

			assertEquals(firstMatchedCharacterIndex, 1)
			assertEquals(lastMatchedCharacterIndex, string.len(embeddedLibraryVersion))
			assertEquals(type(string.match(embeddedLibraryVersion, "%d+.%d+.%d+")), "string")
		end)
	end)
end)
