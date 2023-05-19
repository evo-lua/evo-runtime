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
end)
