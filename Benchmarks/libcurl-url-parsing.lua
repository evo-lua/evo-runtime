local console = require("console")
local curl = require("curl")
local ffi = require("ffi")
local openssl = require("openssl")

local tinsert = table.insert

local assertions = require("assertions")
local assertEquals = assertions.assertEquals

local SAMPLE_SIZE = 100000
printf("Generating %d randomized samples of varying lengths", SAMPLE_SIZE)
console.startTimer("Generate random samples")

local inputs = {}

local MAX_EXPECTED_TOKEN_LENGTH = 256

for i = 1, SAMPLE_SIZE, 1 do
	local alternatingProtocol = (i % 2 == 0) and "https" or "http"
	local randomHost = openssl.hex(openssl.random(MAX_EXPECTED_TOKEN_LENGTH)) .. ".com"
	local randomPath = "/"
		.. openssl.hex(openssl.random(MAX_EXPECTED_TOKEN_LENGTH))
		.. "/"
		.. openssl.hex(openssl.random(MAX_EXPECTED_TOKEN_LENGTH))
		.. (i % 2 == 0 and ".html" or ".htm")

	local randomURL = alternatingProtocol .. "://" .. randomHost .. randomPath
	local fixture = {
		url = randomURL,
		protocol = alternatingProtocol,
		host = randomHost,
		path = randomPath,
	}
	tinsert(inputs, fixture)
end

console.stopTimer("Generate random samples")

local function libcurl_lowlevel(fixture)
	local handle = curl.bindings.curl_url()
	assert(handle)

	local status = curl.bindings.curl_url_set(handle, ffi.C.CURLUPART_URL, fixture.url, 0)
	assertEquals(tonumber(status), ffi.C.CURLUE_OK)

	local host = ffi.new("char*")
	local hostPtr = ffi.new("char*[1]")
	hostPtr[0] = host
	ffi.gc(host, curl.bindings.curl_free)

	status = curl.bindings.curl_url_get(handle, ffi.C.CURLUPART_HOST, hostPtr, 0)
	assertEquals(tonumber(status), ffi.C.CURLUE_OK)
	assertEquals(ffi.string(hostPtr[0]), fixture.host)

	local path = ffi.new("char*")
	local pathPtr = ffi.new("char*[1]")
	pathPtr[0] = path
	ffi.gc(path, curl.bindings.curl_free)

	status = curl.bindings.curl_url_get(handle, ffi.C.CURLUPART_PATH, pathPtr, 0)
	assertEquals(tonumber(status), ffi.C.CURLUE_OK)
	assertEquals(ffi.string(pathPtr[0]), fixture.path)

	curl.bindings.curl_url_cleanup(handle)
end

local function libcurl_lua(fixture)
	local url = curl.url()
	assert(url)
	assert(url:set("url", fixture.url))
	assertEquals(url:get("host"), fixture.host)
	assertEquals(url:get("path"), fixture.path)
end

math.randomseed(os.clock())
local availableBenchmarks = {
	function()
		local label = "[FFI] URL parsing using the curl APIs directly (manual GC handling)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			libcurl_lowlevel(inputs[i])
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[FFI] URL parsing using the high-level URL interface (Lua wrapper)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			libcurl_lua(inputs[i])
		end
		console.stopTimer(label)
	end,
}

table.shuffle(availableBenchmarks)

for _, benchmark in ipairs(availableBenchmarks) do
	benchmark()
end
