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

	describe("parse", function()
		it("should parse a JSON string into a Lua table", function()
			local luaTable = { result = true, count = 42 }
			local jsonString = '{"result":true, "count":42}'
			local jsonTable = json.parse(jsonString)
			assertEquals(jsonTable, luaTable)
		end)
	end)

	describe("stringify", function()
		it("should stringify a Lua table into a JSON string", function()
			assertEquals(json.stringify({ x = 5 }), '{"x":5}')
			assertEquals(json.stringify({ 3, "false", false }), '[3,"false",false]')
			assertEquals(json.stringify({ x = { 10, json.null, 42 } }), '{"x":[10,null,42]}')
			assertEquals(json.stringify({ x = { 10, nil, 42 } }), '{"x":[10]}')
		end)
	end)
end)
