local ffi = require("ffi")
local json = require("json")

describe("json", function()
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

		it("should be an alias of json.decode", function()
			assertEquals(json.parse, json.decode)
		end)
	end)

	describe("stringify", function()
		it("should stringify a Lua table into a JSON string", function()
			assertEquals(json.stringify({ x = 5 }), '{"x":5}')
			assertEquals(json.stringify({ 3, "false", false }), '[3,"false",false]')
			assertEquals(json.stringify({ x = { 10, json.null, 42 } }), '{"x":[10,null,42]}')
			assertEquals(json.stringify({ x = { 10, nil, 42 } }), '{"x":[10]}')
		end)

		it("should forward the encoding options if any have been passed", function()
			local input = { result = true, count = 42 }
			local expectedOutput = '{\n\t"count": 42,\n\t"result": true\n}'
			local encodingOptions = {
				prettier = true,
				sort_keys = true,
			}
			local formattedInput = json.stringify(input, encodingOptions)
			assertEquals(formattedInput, expectedOutput)
		end)

		it("should be an alias of json.encode", function()
			assertEquals(json.stringify, json.encode)
		end)

		it("should propagate encoding errors to the Lua environment", function()
			assertThrows(function()
				json.stringify(print)
			end, format(
				"Cannot encode value %s (only JSON-compatible primitive types are supported)",
				tostring(print)
			))
		end)

		it("should be able to stringify cdata values", function()
			local cdata = ffi.new("uint32_t", 42)
			assertEquals(json.stringify({ cdata = cdata }), '{"cdata":"' .. tostring(cdata) .. '"}')
		end)
	end)

	describe("pretty", function()
		it("should return a human-readable JSON string if a Lua table was given", function()
			local input = { result = true, count = 42 }
			local expectedOutput = '{\n    "count": 42,\n    "result": true\n}'
			local formattedInput = json.pretty(input)
			assertEquals(formattedInput, expectedOutput)
		end)

		it("should return a human-readable JSON string if a JSON string was given", function()
			local input = '{"result":true,"count":42}'
			local expectedOutput = '{\n    "count": 42,\n    "result": true\n}'
			local formattedInput = json.pretty(input)
			assertEquals(formattedInput, expectedOutput)
		end)

		it("should return nil if an invalid input was given", function()
			assertFailure(function()
				return json.pretty(42)
			end, "string or table expected, got number")
		end)
	end)

	describe("prettier", function()
		it("should return a human-readable JSON string if a Lua table was given", function()
			local input = { result = true, count = 42 }
			local expectedOutput = '{\n\t"count": 42,\n\t"result": true\n}'
			local formattedInput = json.prettier(input)
			assertEquals(formattedInput, expectedOutput)
		end)

		it("should return a human-readable JSON string if a JSON string was given", function()
			local input = '{"result":true,"count":42}'
			local expectedOutput = '{\n\t"count": 42,\n\t"result": true\n}'
			local formattedInput = json.prettier(input)
			assertEquals(formattedInput, expectedOutput)
		end)

		it("should return nil if an invalid input was given", function()
			assertFailure(function()
				return json.prettier(42)
			end, "string or table expected, got number")
		end)
	end)
end)
