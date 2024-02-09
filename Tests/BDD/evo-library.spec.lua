local console = require("console")
local evo = require("evo")
local transform = require("transform")
local uv = require("uv")

describe("evo", function()
	describe("showVersionStrings", function()
		it("should show versioning information", function()
			console.capture()
			evo.showVersionStrings()
			local capturedOutput = console.release()
			capturedOutput = transform.strip(capturedOutput)

			local VERSION = "%d+.%d+.%d+"
			local HASH = "[a-f0-9]+"
			local WHITESPACE = "%s+"

			local runtimeVersion = capturedOutput:match("This is Evo.lua v" .. VERSION)
			local engineVersion = capturedOutput:match("powered by LuaJIT " .. VERSION)
			local documentationLink = capturedOutput:match("https://evo%-lua%.github%.io/")

			local hasRuntimeVersion = (runtimeVersion ~= nil)
			local hasEngineVersion = (engineVersion ~= nil)
			local hasEmbeddedLibraryVersions = {
				glfw = (capturedOutput:match("glfw" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				labsound = (capturedOutput:match("labsound" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				libuv = (capturedOutput:match("libuv" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				lpeg = (capturedOutput:match("lpeg" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				miniz = (capturedOutput:match("miniz" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				rapidjson = (capturedOutput:match("rapidjson" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				openssl = (capturedOutput:match("openssl" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				pcre2 = (capturedOutput:match("pcre2" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				rml = (capturedOutput:match("rml" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				stbi = (capturedOutput:match("stbi" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				stduuid = (capturedOutput:match("stduuid" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				uws = (capturedOutput:match("uws" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				wgpu = (capturedOutput:match("wgpu" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				webview = (capturedOutput:match("webview" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
				zlib = (capturedOutput:match("zlib" .. WHITESPACE .. VERSION .. WHITESPACE .. HASH) ~= nil),
			}
			local hasDocumentationLink = (documentationLink ~= nil)

			assertTrue(hasRuntimeVersion)
			assertTrue(hasEngineVersion)
			assertTrue(hasEmbeddedLibraryVersions.glfw)
			assertTrue(hasEmbeddedLibraryVersions.labsound)
			assertTrue(hasEmbeddedLibraryVersions.lpeg)
			assertTrue(hasEmbeddedLibraryVersions.libuv)
			assertTrue(hasEmbeddedLibraryVersions.miniz)
			assertTrue(hasEmbeddedLibraryVersions.rapidjson)
			assertTrue(hasEmbeddedLibraryVersions.openssl)
			assertTrue(hasEmbeddedLibraryVersions.pcre2)
			assertTrue(hasEmbeddedLibraryVersions.rml)
			assertTrue(hasEmbeddedLibraryVersions.stbi)
			assertTrue(hasEmbeddedLibraryVersions.stduuid)
			assertTrue(hasEmbeddedLibraryVersions.uws)
			assertTrue(hasEmbeddedLibraryVersions.wgpu)
			assertTrue(hasEmbeddedLibraryVersions.webview)
			assertTrue(hasEmbeddedLibraryVersions.zlib)
			assertTrue(hasDocumentationLink)
		end)
	end)

	describe("displayHelpText", function()
		before(function()
			-- Handlers may have been removed by the C_CommandLine tests
			C_CommandLine.UnregisterAllCommands()
			evo.setUpCommandLineInterface()
		end)

		it("should display the usage instructions", function()
			console.capture()
			evo.displayHelpText()
			local capturedOutput = console.release()

			local USAGE_PATTERN = "Usage: evo %[ script%.lua %| command %] %.%.%."

			local usageInfoText = capturedOutput:match(USAGE_PATTERN)
			assertEquals(usageInfoText, "Usage: evo [ script.lua | command ] ...")
		end)

		it("should display the list of available commands", function()
			console.capture()
			evo.displayHelpText()
			local capturedOutput = console.release()

			local evalCommandInfo =
				capturedOutput:match("%-e" .. "%s+" .. "eval" .. "%s+" .. "Evaluate expressions live or from input")
			local helpCommandInfo =
				capturedOutput:match("%-h" .. "%s+" .. "help" .. "%s+" .. "Display usage instructions %(this text%)")
			local versionCommandInfo =
				capturedOutput:match("%-v" .. "%s+" .. "version" .. "%s+" .. "Show versioning information")
			local buildCommandInfo =
				capturedOutput:match("%-b" .. "%s+" .. "build" .. "%s+" .. "Create a self%-contained executable")

			assertEquals(evalCommandInfo, "-e\teval\t\tEvaluate expressions live or from input")
			assertEquals(helpCommandInfo, "-h\thelp\t\tDisplay usage instructions (this text)")
			assertEquals(versionCommandInfo, "-v\tversion\t\tShow versioning information")
			assertEquals(buildCommandInfo, "-b\tbuild\t\tCreate a self-contained executable")
		end)
	end)

	describe("signals", function()
		it("should be exported even if there are no dereferenced signal handlers", function()
			assertEquals(type(evo.signals), "table")
		end)

		it("should store the dereferenced SIGPIPE handler when one is required", function()
			-- This is a no-op on Windows
			if not uv.constants.SIGPIPE then
				return
			end

			local sigpipeHandler = evo.signals.SIGPIPE
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
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/LabSound/LabSound"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/LuaJIT/LuaJIT"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/PCRE2Project/pcre2"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/brimworks/lua-zlib"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/freetype/freetype"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/gfx-rs/wgpu-native"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/glfw/glfw"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/kikito/inspect.lua"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/luvit/luv"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/madler/zlib"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/mariusbancila/stduuid"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/mikke89/RmlUi"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/nothings/stb"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/openssl/openssl"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/richgel999/miniz"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/roberto-ieru/LPeg"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/rrthomas/lrexlib"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/starwing/luautf8"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/uNetworking/uWebSockets"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/webview/webview"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/xpol/lua-rapidjson"])
			assertSubmoduleVersion(evo.embeddedLibraryVersions["deps/zhaog/lua-openssl"])

			assertEquals(table.count(evo.embeddedLibraryVersions), 22)
		end)
	end)
end)
