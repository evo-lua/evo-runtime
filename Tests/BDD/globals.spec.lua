local evo = require("evo")
local bdd = require("bdd")

local globalAliases = {
	["buffer"] = require("string.buffer"),
	["describe"] = bdd.describe,
	["dump"] = debug.dump,
	["extend"] = evo.extend,
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

	it("should export important defines from the native entry point", function()
		local runtimeVersionDefinedAtBuildTime = EVO_VERSION
		-- Technically git describe adds more information in between releases, but it's still "semver-like" enough
		assertEquals(type(runtimeVersionDefinedAtBuildTime), "string")

		local expectedVersionStringPattern = "(v%d+%.%d+%.%d+.*)" --vMAJOR.MINOR.PATCH-optionalGitDescribeSuffix
		local versionString = string.match(runtimeVersionDefinedAtBuildTime, expectedVersionStringPattern)

		assertEquals(type(versionString), "string")
	end)

	describe("printf", function()
		it("should output formatted strings to stdout", function()
			local console = require("console")
			console.capture()
			printf("Hello %s", "printf")
			local capturedOutput = console.release()
			assertEquals(capturedOutput, "Hello printf\n")
		end)
	end)

	describe("extend", function()
		it("should still work if the prototype object doesn't have a metatable", function()
			local child = {}
			local parent = {}
			function parent:hello() end

			extend(child, parent)
			assertEquals(child.hello, parent.hello)
		end)

		it("should set up a metatable such that the child inherits the prototype's functionality", function()
			local child = {}
			local parent = {}
			function parent:thisFunctionShouldBeInherited() end

			extend(child, parent)
			assertEquals(child.thisFunctionShouldBeInherited, parent.thisFunctionShouldBeInherited)
		end)

		it("should copy all existing fields from the prototype's metatable", function()
			local child = {}
			local parent = {}
			local grandparent = {}
			function parent:thisFunctionShouldBeInherited() end
			function grandparent:thisFunctionShouldAlsoBeInherited() end

			extend(parent, grandparent)
			extend(child, parent)

			assertEquals(child.thisFunctionShouldBeInherited, parent.thisFunctionShouldBeInherited)
			assertEquals(child.thisFunctionShouldAlsoBeInherited, grandparent.thisFunctionShouldAlsoBeInherited)
			assertEquals(parent.thisFunctionShouldAlsoBeInherited, grandparent.thisFunctionShouldAlsoBeInherited)
		end)
	end)
end)
