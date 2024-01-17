local evo = require("evo")
local ffi = require("ffi")
local bdd = require("bdd")
local console = require("console")

local globalAliases = {
	["after"] = bdd.after,
	["before"] = bdd.before,
	["buffer"] = require("string.buffer"),
	["describe"] = bdd.describe,
	["dump"] = debug.dump,
	["extend"] = evo.extend,
	["format"] = string.format,
	["it"] = bdd.it,
	["path"] = require("path"),
	["printf"] = console.printf,
	["cast"] = ffi.cast,
	["cdef"] = ffi.cdef,
	["define"] = ffi.cdef,
	["new"] = ffi.new,
	["sizeof"] = ffi.sizeof,
	["typeof"] = ffi.typeof,
}

local globalNamespaces = {
	["C_Runtime"] = C_Runtime,
}

describe("_G", function()
	for globalName, target in pairs(globalAliases) do
		it("should export global alias " .. globalName, function()
			local alias = _G[globalName]
			assert(alias == target, globalName)
		end)
	end

	for globalName, target in pairs(globalNamespaces) do
		it("should export global namespace " .. globalName, function()
			local alias = _G[globalName]
			assert(alias == target, globalName)
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
