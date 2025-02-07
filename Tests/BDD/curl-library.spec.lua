local curl = require("curl")
local ffi = require("ffi")
local crypto = require("crypto")
local zlib = require("zlib")

describe("curl", function()
	describe("version_info", function()
		it("should return a table containing curl versioning information", function()
			local infoTable = curl.version_info()

			assertTrue(infoTable.feature_names.AsynchDNS)
			assertTrue(infoTable.feature_names.IPv6)
			assertTrue(infoTable.feature_names.Largefile)
			assertTrue(infoTable.feature_names.libz)
			assertTrue(infoTable.feature_names.SSL)
			assertTrue(infoTable.feature_names.threadsafe)

			assertTrue(infoTable.cainfo ~= "")
			assertTrue(infoTable.capath ~= "")

			-- zlib versions don't include a patch version if it's a clean major/minor release
			local zlibVersionMajor, zlibVersionMinor, zlibVersionPatch = zlib.version()
			local semanticZlibVersionString =
				format("%d.%d.%d", zlibVersionMajor, zlibVersionMinor, zlibVersionPatch or 0)
			assertEquals(infoTable.libz_version, semanticZlibVersionString)

			assertTrue(infoTable.protocols.dict)
			assertTrue(infoTable.protocols.file)
			assertTrue(infoTable.protocols.ftp)
			assertTrue(infoTable.protocols.ftps)
			assertTrue(infoTable.protocols.http)
			assertTrue(infoTable.protocols.https)
			assertTrue(infoTable.protocols.imap)
			assertTrue(infoTable.protocols.imaps)
			assertTrue(infoTable.protocols.mqtt)
			assertTrue(infoTable.protocols.pop3)
			assertTrue(infoTable.protocols.pop3s)
			assertTrue(infoTable.protocols.rtsp)
			assertTrue(infoTable.protocols.rtsp)
			assertTrue(infoTable.protocols.smbs)
			assertTrue(infoTable.protocols.smtp)
			assertTrue(infoTable.protocols.smtps)
			assertTrue(infoTable.protocols.telnet)
			assertTrue(infoTable.protocols.tftp)
			assertTrue(infoTable.protocols.ws)
			assertTrue(infoTable.protocols.wss)

			assertEquals(infoTable.ssl_version, "OpenSSL/" .. crypto.version())
		end)
	end)

	describe("version", function()
		it("should return the embedded libcurl version in semver format", function()
			local versionInfo = curl.version_info()
			local versionString, versionNumber, revision = curl.version()
			assertEquals(versionInfo.version, versionString)
			assertEquals(versionInfo.version_num, versionNumber)
			assertEquals(versionInfo.age, revision)
			assertEquals(versionInfo.age, tonumber(curl.bindings.CURLVERSION_NOW))

			assertTrue(type(versionNumber) == "number")
			local firstMatchedCharacterIndex, lastMatchedCharacterIndex = string.find(versionString, "%d+.%d+.%d+")

			assertEquals(firstMatchedCharacterIndex, 1)
			assertEquals(lastMatchedCharacterIndex, string.len(versionString))
			assertEquals(type(string.match(versionString, "%d+.%d+.%d+")), "string")
		end)
	end)

	describe("bindings", function()
		it("should export all of the URL parsing APIs", function()
			local handle = curl.bindings.curl_url()
			assert(handle)

			local URL = "http://asdf.com/hello/123.html"
			local status = curl.bindings.curl_url_set(handle, ffi.C.CURLUPART_URL, URL, 0)
			-- assertEquals(status, ffi.C.CURLUE_OK) -- should probably be auto-converted (?)
			assertEquals(tonumber(status), ffi.C.CURLUE_OK)

			-- These ergonomics are... not great
			local host = ffi.new("char*") -- TODO curl_free it?
			local hostPtr = ffi.new("char*[1]")
			hostPtr[0] = host

			status = curl.bindings.curl_url_get(handle, ffi.C.CURLUPART_HOST, hostPtr, 0)
			assertEquals(tonumber(status), ffi.C.CURLUE_OK)
			assertEquals(ffi.string(hostPtr[0]), "asdf.com")

			local path = ffi.new("char*") -- TODO curl_free it?
			local pathPtr = ffi.new("char*[1]")
			pathPtr[0] = path
			status = curl.bindings.curl_url_get(handle, ffi.C.CURLUPART_PATH, pathPtr, 0)
			assertEquals(tonumber(status), ffi.C.CURLUE_OK)
			assertEquals(ffi.string(pathPtr[0]), "/hello/123.html")

			curl.bindings.curl_url_cleanup(handle)
		end)
	end)
end)
