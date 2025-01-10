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

	describe("embeddedLibraryVersions", function()
		it("should export the auto-generated versioning information for all embedded submodules", function()
			local FULL_GIT_COMMIT_HASH_LENGTH = 40
			local function assertSubmoduleVersion(entry)
				local gitCommitHash = entry.commit
				local gitReleaseTag = entry.tag
				assertEquals(type(gitCommitHash), "string")
				assertEquals(#gitCommitHash, FULL_GIT_COMMIT_HASH_LENGTH)
				assertEquals(type(gitReleaseTag), "string")
			end
			assertSubmoduleVersion(runtime.submodules["deps/LabSound/LabSound"])
			assertSubmoduleVersion(runtime.submodules["deps/LuaJIT/LuaJIT"])
			assertSubmoduleVersion(runtime.submodules["deps/PCRE2Project/pcre2"])
			assertSubmoduleVersion(runtime.submodules["deps/brimworks/lua-zlib"])
			assertSubmoduleVersion(runtime.submodules["deps/freetype/freetype"])
			assertSubmoduleVersion(runtime.submodules["deps/gfx-rs/wgpu-native"])
			assertSubmoduleVersion(runtime.submodules["deps/glfw/glfw"])
			assertSubmoduleVersion(runtime.submodules["deps/kikito/inspect.lua"])
			assertSubmoduleVersion(runtime.submodules["deps/luvit/luv"])
			assertSubmoduleVersion(runtime.submodules["deps/madler/zlib"])
			assertSubmoduleVersion(runtime.submodules["deps/mariusbancila/stduuid"])
			assertSubmoduleVersion(runtime.submodules["deps/mikke89/RmlUi"])
			assertSubmoduleVersion(runtime.submodules["deps/nothings/stb"])
			assertSubmoduleVersion(runtime.submodules["deps/openssl/openssl"])
			assertSubmoduleVersion(runtime.submodules["deps/richgel999/miniz"])
			assertSubmoduleVersion(runtime.submodules["deps/roberto-ieru/LPeg"])
			assertSubmoduleVersion(runtime.submodules["deps/rrthomas/lrexlib"])
			assertSubmoduleVersion(runtime.submodules["deps/starwing/luautf8"])
			assertSubmoduleVersion(runtime.submodules["deps/uNetworking/uWebSockets"])
			assertSubmoduleVersion(runtime.submodules["deps/webview/webview"])
			assertSubmoduleVersion(runtime.submodules["deps/xpol/lua-rapidjson"])
			assertSubmoduleVersion(runtime.submodules["deps/zhaog/lua-openssl"])
			assertSubmoduleVersion(runtime.submodules["deps/Tencent/rapidjson"])

			assertEquals(table.count(runtime.submodules), 24)
		end)
	end)
end)
