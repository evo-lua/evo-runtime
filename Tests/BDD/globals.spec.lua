local evo = require("evo")
local bdd = require("bdd")

local globalAliases = {
	["buffer"] = require("string.buffer"),
	["describe"] = bdd.describe,
	["dump"] = debug.dump,
	["format"] = string.format,
	["it"] = bdd.it,
	["printf"] = evo.printf,
}

local globalNamespaces = {
	["C_Runtime"] = C_Runtime,
}

describe("_G", function()
	for globalName, target in pairs(globalAliases) do
		it("should export global alias " .. globalName, function()
			local alias = _G[globalName]
			assertEquals(alias, target)
		end)
	end

	for globalName, target in pairs(globalNamespaces) do
		it("should export global namespace " .. globalName, function()
			local alias = _G[globalName]
			assertEquals(alias, target)
		end)
	end

end)
