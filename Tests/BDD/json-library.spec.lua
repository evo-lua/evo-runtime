describe("json", function()
	local json = require("json")
	local exportedFunctions = {
		"array",
		"decode",
		"dump",
		"encode",
		"load",
		"object",
	}

	it("should export all lua-rapidjson functions", function()
		for _, functionName in ipairs(exportedFunctions) do
			local exportedFunction = json[functionName]
			assertEquals(type(exportedFunction), "function", "Should export function " .. functionName)
		end
	end)

	describe("version", function()
		it("should be a semantic version string", function()
			local versionString = json.version()
			local major, minor, patch = string.match(versionString, "(%d+).(%d+).(%d+)")

			assertEquals(type(major), "string")
			assertEquals(type(minor), "string")
			assertEquals(type(patch), "string")
		end)
	end)
end)
