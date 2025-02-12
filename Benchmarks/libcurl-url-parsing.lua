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

-- math.randomseed(openssl.random(32))
for i = 1, SAMPLE_SIZE, 1 do
	-- tinsert(inputs, openssl.random(4))
	-- tinsert(inputs, openssl.random(8))
	-- tinsert(inputs, openssl.random(16))
	-- tinsert(inputs, openssl.random(32))
	-- tinsert(inputs, openssl.random(64))
	-- tinsert(inputs, openssl.random(128))
	-- tinsert(inputs, openssl.random(256))
	-- tinsert(inputs, openssl.random(512))
	-- tinsert(inputs, openssl.random(1024))
	-- MakeRandom("%s://%s.%s/%s/%s%s")
	local alternatingProtocol = (i % 2 == 0) and "https" or "http" -- TODO pick one from the list of curl-supported ones, or maybe even a custom one (needs feature flags to be enabled)
	local randomHost = openssl.hex(openssl.random(MAX_EXPECTED_TOKEN_LENGTH)) .. ".com"
	local randomPath = "/"
		.. openssl.hex(openssl.random(MAX_EXPECTED_TOKEN_LENGTH))
		.. "/"
		.. openssl.hex(openssl.random(MAX_EXPECTED_TOKEN_LENGTH))
		.. (i % 2 == 0 and ".html" or ".htm")
	-- tinsert(inputs, openssl.random(2500))
	-- tinsert(inputs, openssl.random(5000))
	-- tinsert(inputs, openssl.random(10000))
	-- tinsert(inputs, openssl.random(100000))
	-- TODO format
	local randomURL = alternatingProtocol .. "://" .. randomHost .. randomPath -- TODO global path = remove alias?
	local fixture = {
		url = randomURL,
		protocol = alternatingProtocol,
		host = randomHost,
		path = randomPath,
		-- TODO test the other supported components (all 12 of them)?
	}
	tinsert(inputs, fixture)
	-- print(i, randomURL)
end

console.stopTimer("Generate random samples")

-- local URL = "http://asdf.com/hello/123.html"
local function libcurl_lowlevel(fixture)
	local handle = curl.bindings.curl_url()
	assert(handle)

	local status = curl.bindings.curl_url_set(handle, ffi.C.CURLUPART_URL, fixture.url, 0)
	assertEquals(tonumber(status), ffi.C.CURLUE_OK)

	-- These ergonomics are... not great -> cstring.ref / ffi.ref for all types?
	local host = ffi.new("char*")
	local hostPtr = ffi.new("char*[1]")
	hostPtr[0] = host
	ffi.gc(host, curl.bindings.curl_free)

	status = curl.bindings.curl_url_get(handle, ffi.C.CURLUPART_HOST, hostPtr, 0)
	assertEquals(tonumber(status), ffi.C.CURLUE_OK)
	-- dump(fixture)
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

-- local URL = "http://asdf.com/hello/123.html"
local function libcurl_cpp(fixture)
	local result = curl.bindings.curl_decode_url(fixture.url)
	-- TODO check it
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
		local label = "[FFI] Low-level API (tedious and slow, but the most flexible)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			libcurl_lowlevel(inputs[i])
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[FFI] One-shot C++ conversion (fast but less flexible)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			libcurl_cpp(inputs[i])
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[FFI] Lua-friendly wrapper (safer, but slower)"
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
