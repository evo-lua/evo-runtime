local console = require("console")
local evo = require("evo")

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
				libuv = (capturedOutput:match("libuv" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				openssl = (capturedOutput:match("openssl" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				stduuid = (capturedOutput:match("stduuid" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				webview = (capturedOutput:match("webview" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
				zlib = (capturedOutput:match("zlib" .. WHITESPACE .. VERSION_PATTERN) ~= nil),
			}
			local hasDocumentationLink = (documentationLink ~= nil)

			assertTrue(hasRuntimeVersion)
			assertTrue(hasEngineVersion)
			assertTrue(hasEmbeddedLibraryVersions.libuv)
			assertTrue(hasEmbeddedLibraryVersions.openssl)
			assertTrue(hasEmbeddedLibraryVersions.stduuid)
			assertTrue(hasEmbeddedLibraryVersions.webview)
			assertTrue(hasEmbeddedLibraryVersions.zlib)
			assertTrue(hasDocumentationLink)
		end)
	end)
end)
