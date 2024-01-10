local console = require("console")
local evo = require("evo")
local uv = require("uv")

describe("evo", function()
	describe("showVersionStrings", function()
		it("should show versioning information", function()
			console.capture()
			evo.showVersionStrings()
			local capturedOutput = console.release()

			local VERSION_PATTERN = "%d+.%d+.%d+"
			local WHITESPACE = "%s+"

			local runtimeVersion = capturedOutput:match("This is Evo.lua v" .. VERSION_PATTERN)
			local engineVersion = capturedOutput:match("powered by LuaJIT " .. VERSION_PATTERN)
			local documentationLink = capturedOutput:match("https://evo%-lua%.github%.io/")

			local hasRuntimeVersion = (runtimeVersion ~= nil)
			local hasEngineVersion = (engineVersion ~= nil)
			local hasEmbeddedLibraryVersions = {
				glfw = (capturedOutput:match("glfw" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				labsound = (capturedOutput:match("labsound" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				libuv = (capturedOutput:match("libuv" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				lpeg = (capturedOutput:match("lpeg" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				miniz = (capturedOutput:match("miniz" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				rapidjson = (capturedOutput:match("rapidjson" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				openssl = (capturedOutput:match("openssl" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				pcre2 = (capturedOutput:match("pcre2" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				rml = (capturedOutput:match("rml" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				stbi = (capturedOutput:match("stbi" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				stduuid = (capturedOutput:match("stduuid" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				uws = (capturedOutput:match("uws" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				wgpu = (capturedOutput:match("wgpu" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				webview = (capturedOutput:match("webview" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				zlib = (capturedOutput:match("zlib" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
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
				capturedOutput:match("%-e" .. "%s+" .. "eval" .. "%s+" .. "Evaluate the next token as a Lua chunk")
			local helpCommandInfo =
				capturedOutput:match("%-h" .. "%s+" .. "help" .. "%s+" .. "Display usage instructions %(this text%)")
			local versionCommandInfo =
				capturedOutput:match("%-v" .. "%s+" .. "version" .. "%s+" .. "Show versioning information")
			local buildCommandInfo =
				capturedOutput:match("%-b" .. "%s+" .. "build" .. "%s+" .. "Create a self%-contained executable")

			assertEquals(evalCommandInfo, "-e\teval\t\tEvaluate the next token as a Lua chunk")
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
end)
