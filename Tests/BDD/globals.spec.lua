local bdd = require("bdd")

local globalAliases = {
	["buffer"] = require("string.buffer"),
	["describe"] = bdd.describe,
	["dump"] = debug.dump,
	["format"] = string.format,
	["it"] = bdd.it,
}

describe("globals", function()
	for globalName, target in pairs(globalAliases) do
		it("should export global alias " .. globalName, function()
			local alias = _G[globalName]
			assertEquals(alias, target)
		end)
	end
end)
