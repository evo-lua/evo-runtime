local runtime = require("runtime")

describe("runtime", function()
	describe("version", function()
		it("should export the EVO_VERSION define from the native entry point", function()
			local runtimeVersionDefinedAtBuildTime, majorVersion, minorVersion, patchVersion = runtime.version()
			-- Technically git describe adds more information in between releases, but it's still "semver-like" enough
			assertEquals(type(runtimeVersionDefinedAtBuildTime), "string")

			local expectedVersionStringPattern = "(v%d+%.%d+%.%d+.*)" --vMAJOR.MINOR.PATCH-optionalGitDescribeSuffix
			local versionString = string.match(runtimeVersionDefinedAtBuildTime, expectedVersionStringPattern)

			assertEquals(type(versionString), "string")
			assertEquals(type(majorVersion), "number")
			assertEquals(type(minorVersion), "number")
			assertEquals(type(patchVersion), "number")
		end)
	end)
end)
