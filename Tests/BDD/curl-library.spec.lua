local curl = require("curl")
local ffi = require("ffi")
local crypto = require("crypto")
local zlib = require("zlib")

local jit = require("jit")
jit.off(curl.free) -- Hacky; no proper way to test cleanup is actually performed yet

describe("curl", function()
	describe("url", function()
		it("should attach a GC finalizer to the returned handle", function()
			assertCallsFunction(function()
				curl.url()
			end, ffi.gc)
		end)
	end)

	describe("url_dup", function()
		it("should be able to clone an existing handle", function()
			local parts = {
				scheme = "https",
				user = "sbømwøllen",
				password = "letmein",
				host = "[fe80::1]",
				port = "8080",
				path = "/path/to/success",
				query = "a=1&b=2",
				fragment = "hi",
			}
			local combinedParts = format(
				"%s://%s:%s@%s:%s%s?%s#%s",
				parts.scheme,
				parts.user,
				parts.password,
				parts.host,
				parts.port,
				parts.path,
				parts.query,
				parts.fragment
			)

			local url = curl.url()
			local href = "http://user:password@[fe80::20c:29ff:fe9c:409b%25eth0]:1234/hello/world?answer=42#bye"
			url:set("url", href)

			-- The duplicate handle should be completely self-contained as curl clones the parts
			local duplicate = url:dup()
			assertEquals(url:get("url"), duplicate:get("url"))
			assertEquals(duplicate:get("url"), href)
			for part, value in pairs(parts) do
				-- Sanity check: If there's a problem with the test fixtures, the API returns a failure tuple
				assert(url:get(part))
				assert(duplicate:get(part))

				assert(duplicate:set(part, value))
				assertEquals(duplicate:get(part), value)
			end
			assertEquals(url:get("url"), href)

			assert(duplicate:get("url"))
			assertEquals(duplicate:get("url"), combinedParts)

			local different = "https://something.else.com/"
			url:set("url", different)
			assertEquals(url:get("url"), different)
		end)

		it("should attach a GC finalizer to clean up the allocated part buffer", function()
			local url = curl.url()
			url:set("url", "http://example.org")
			assertCallsFunction(function()
				url:dup()
			end, ffi.gc)
		end)
	end)

	describe("url_strerror", function()
		it("should return human-readable error strings for all known error codes", function()
			local firstValidOffset = tonumber(ffi.C.CURLUE_OK)
			local lastValidOffset = tonumber(ffi.C.CURLUE_LAST)

			local numCheckedMembers = 0
			for relativeOffset = firstValidOffset, lastValidOffset do
				local nextOffset = firstValidOffset + relativeOffset
				local messageString = curl.url_strerror(nextOffset)
				assertEquals(type(messageString), "string")
				numCheckedMembers = numCheckedMembers + 1
			end

			assertEquals(numCheckedMembers, lastValidOffset + 1)
		end)
	end)

	describe("url_get", function()
		it("should fail if an invalid handle was provided", function()
			assertFailure(function()
				return curl.url_get()
			end, curl.url_strerror(ffi.C.CURLUE_BAD_HANDLE))
		end)

		it("should be able to get all supported URL parts", function()
			local url = curl.url()
			local href = "http://admin:topsecret@[fe80::20c:29ff:fe9c:409b%25eth0]:1234/hello/world?answer=42#bye"
			url:set("url", href)

			assertEquals(url:get("scheme"), "http")
			assertEquals(url:get("user"), "admin")
			assertEquals(url:get("password"), "topsecret")
			assertEquals(url:get("host"), "[fe80::20c:29ff:fe9c:409b]")
			assertEquals(url:get("zone"), "eth0")
			assertEquals(url:get("port"), "1234")
			assertEquals(url:get("path"), "/hello/world")
			assertEquals(url:get("query"), "answer=42")
			assertEquals(url:get("fragment"), "bye")
			assertEquals(url:get("options"), nil)
		end)

		it("should get the encoded URL if no part name was provided", function()
			local url = curl.url()
			local href = "http://example.org/12345"
			url:set("url", href)
			local part = curl.url_get(url)
			assertEquals(part, href)
			assertEquals(url:get(), href)
		end)

		it("should get the encoded URL if an invalid part name was provided", function()
			local url = curl.url()
			local href = "http://example.org/12345"
			url:set("url", href)
			local part = curl.url_get(url, "")
			assertEquals(part, href)
		end)

		it("should clean up the allocated part buffer if curl didn't return an error", function()
			local url = curl.url()
			assert(url:set("url", "http://example.org"))
			assertCallsFunction(function()
				assert(url:get("url"))
			end, curl.free)
		end)
	end)

	describe("url_set", function()
		it("should fail if an invalid handle was provided", function()
			assertFailure(function()
				return curl.url_set()
			end, curl.url_strerror(ffi.C.CURLUE_BAD_HANDLE))
		end)

		it("should be able to set all supported URL parts", function()
			local url = curl.url()
			local href = "http://admin:topsecret@[fe80::20c:29ff:fe9c:409b%25eth0]:1234/hello/world?answer=42#bye"

			assert(url:set("scheme", "http"))
			assert(url:set("user", "admin"))
			assert(url:set("password", "topsecret"))
			assert(url:set("host", "[fe80::20c:29ff:fe9c:409b]"))
			assert(url:set("zone", "eth0"))
			assert(url:set("port", "1234"))
			assert(url:set("path", "/hello/world"))
			assert(url:set("query", "answer=42"))
			assert(url:set("fragment", "bye"))
			assert(url:get("url"))

			assertEquals(url:get("url"), href)
		end)

		it("should be able to set options for protocols that support it", function()
			local url = curl.url()
			assert(url:set("url", "imap://user:pass;hello@host/file"))
			assertEquals(url:get("options"), "hello")
		end)

		it("should be able to set the port as a number value", function()
			local url = curl.url()
			assert(url:set("url", "pop3://10.0.0.1"))
			assert(url:set("port", 12345))
			assertEquals(url:get("port"), "12345")
		end)

		it("should be able to set and update IPv6 zone IDs via the URL part", function()
			local url = curl.url()

			-- Initialized new handle with zone ID by providing all URL parts
			local withZoneID = "http://admin:topsecret@[fe80::20c:29ff:fe9c:409a%25eth0]:1234/hello/world?answer=42#bye"
			assert(url:set("url", withZoneID))
			assert(url:get("host"))
			assert(url:get("zone"))
			assertEquals(url:get("zone"), "eth0")
			assertEquals(url:get("host"), "[fe80::20c:29ff:fe9c:409a]")

			-- Removed zone ID by replacing all URL parts on the same handle
			local withoutZoneID = "http://admin:topsecret@[fe80::20c:29ff:fe9c:409b]:1234/hello/world?answer=42#bye"
			assert(url:set("url", withoutZoneID))
			assert(url:get("host"))
			assertFailure(function()
				return url:get("zone")
			end, curl.url_strerror(ffi.C.CURLUE_NO_ZONEID))
			assertEquals(url:get("host"), "[fe80::20c:29ff:fe9c:409b]")
			assertEquals(url:get("zone"), nil)
		end)

		it("should be able to set and update IPv6 zone IDs via the HOST part", function()
			local url = curl.url()

			-- Initialized new handle with zone ID by providing HOST part with ZONEID
			local withZoneID = "[fe80::20c:29ff:fe9c:409a%eth0]"
			assert(url:set("host", withZoneID))
			assert(url:get("host"))
			assert(url:get("zone"))
			assertEquals(url:get("zone"), "eth0")
			assertEquals(url:get("host"), withZoneID)

			-- Removed zone ID by replacing only the HOST part on the same handle
			local withoutZoneID = "[fe80::20c:29ff:fe9c:409a]"
			assert(url:set("host", withoutZoneID))
			assert(url:get("host"))
			assertFailure(function()
				return url:get("zone")
			end, curl.url_strerror(ffi.C.CURLUE_NO_ZONEID))
			assertEquals(url:get("host"), withoutZoneID)
			assertEquals(url:get("zone"), nil)
		end)

		it("should be able to set regular IPv6 zone IDs via the HOST part", function()
			local url = curl.url()

			-- Initialized HOST and ZONEID (default format)
			url:set("host", "[fe80::20c:29ff:fe9c:409a%eth1]")
			assert(url:get("host"))
			assert(url:get("zone"))
			assertEquals(url:get("host"), "[fe80::20c:29ff:fe9c:409a%eth1]")
			assertEquals(url:get("zone"), "eth1")
		end)

		it("should be able to set escaped IPv6 zone IDs via the HOST part", function()
			local url = curl.url()
			local href = "[fe80::20c:29ff:fe9c:409d]"

			-- Initialized HOST and ZONEID added later
			assert(url:set("host", href))
			assert(url:get("host"))
			assertFailure(function()
				return url:get("zone")
			end, curl.url_strerror(ffi.C.CURLUE_NO_ZONEID))
			assertEquals(url:get("host"), href)
		end)

		it("should be able to set escaped IPv6 zone IDs via the HOST part", function()
			local url = curl.url()
			local href = "[fe80::20c:29ff:fe9c:4090%25eth3]"

			-- Initialized HOST and ZONEID (escaped/percent-encoding)
			assert(url:set("host", href))
			assert(url:get("host"))
			assert(url:get("zone"))
			assertEquals(url:get("host"), href)
			assertEquals(url:get("zone"), "eth3")
		end)

		it("should be able to set IPv6 zone IDs via the ZONEID part", function()
			-- ZONEID may be set by HOST, URL, or separately (somewhat inconsistently)
			local url = curl.url()
			assert(url:set("host", "[fe80::20c:29ff:fe9c:4090]"))
			assert(url:get("host"))
			assertFailure(function()
				return url:get("zone")
			end, curl.url_strerror(ffi.C.CURLUE_NO_ZONEID))
			assertEquals(url:get("host"), "[fe80::20c:29ff:fe9c:4090]")

			assert(url:set("zone", "eth3"))
			assertEquals(url:get("host"), "[fe80::20c:29ff:fe9c:4090]")
			assertEquals(url:get("zone"), "eth3")
		end)
	end)

	describe("url", function()
		it("should set the URL part if a href string was provided", function()
			local href = "http://example.org/"
			local url = curl.url(href)
			assert(url:get("url"))
			assertEquals(url:get("url"), href)
		end)
	end)

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
			assertEquals(versionInfo.age, tonumber(curl.bindings.curl_version_now()))

			assertTrue(type(versionNumber) == "number")
			local firstMatchedCharacterIndex, lastMatchedCharacterIndex = string.find(versionString, "%d+.%d+.%d+")

			assertEquals(firstMatchedCharacterIndex, 1)
			assertEquals(lastMatchedCharacterIndex, string.len(versionString))
			assertEquals(type(string.match(versionString, "%d+.%d+.%d+")), "string")
		end)
	end)

	describe("bindings", function()
		it("should export libcurl's url interface", function()
			local handle = curl.bindings.curl_url()
			assert(handle)

			local URL = "http://asdf.com/hello/123.html"
			local status = curl.bindings.curl_url_set(handle, ffi.C.CURLUPART_URL, URL, 0)
			assertEquals(tonumber(status), ffi.C.CURLUE_OK)

			local host = ffi.new("char*")
			local hostPtr = ffi.new("char*[1]")
			hostPtr[0] = host
			ffi.gc(host, curl.bindings.curl_free)

			status = curl.bindings.curl_url_get(handle, ffi.C.CURLUPART_HOST, hostPtr, 0)
			assertEquals(tonumber(status), ffi.C.CURLUE_OK)
			assertEquals(ffi.string(hostPtr[0]), "asdf.com")

			local path = ffi.new("char*")
			local pathPtr = ffi.new("char*[1]")
			pathPtr[0] = path
			ffi.gc(path, curl.bindings.curl_free)

			status = curl.bindings.curl_url_get(handle, ffi.C.CURLUPART_PATH, pathPtr, 0)
			assertEquals(tonumber(status), ffi.C.CURLUE_OK)
			assertEquals(ffi.string(pathPtr[0]), "/hello/123.html")

			curl.bindings.curl_url_cleanup(handle)
		end)
	end)
end)
