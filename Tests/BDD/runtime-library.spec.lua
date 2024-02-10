local runtime = require("runtime")
local uv = require("uv")

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

	describe("signals", function()
		it("should be exported even if there are no dereferenced signal handlers", function()
			assertEquals(type(runtime.signals), "table")
		end)

		it("should store the dereferenced SIGPIPE handler when one is required", function()
			-- This is a no-op on Windows
			if not uv.constants.SIGPIPE then
				return
			end

			local sigpipeHandler = runtime.signals.SIGPIPE
			assertEquals(type(sigpipeHandler), "userdata")
		end)
	end)
end)
