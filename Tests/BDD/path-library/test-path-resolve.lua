local path = require("path")

local ffi = require("ffi")
local uv = require("uv")

local posixyCwd = (ffi.os == "Windows")
		and (
			(function()
				-- cwd will have backslashes, but the posix version must always return slashes (even on Windows systems)
				local _ = uv.cwd():gsub(path.win32.separator, path.posix.separator)
				local posixPath = _:sub(_:find(path.posix.separator), #_)
				return posixPath
			end)()
		)
	or uv.cwd()

local windowsCwd = (function()
	local cwd = uv.cwd()
	if ffi.os ~= "Windows" then
		-- cwd will have slashes, but the win32 version must always return backslashes (even on Unixlike systems)
		return cwd:gsub("/", "\\")
	end
	return cwd
end)()

local function getCurrentDeviceRoot()
	local cwd = uv.cwd()
	-- It's always an absolute path, which on windows starts with a disk designator (letter and colon)
	-- Resolving win32 paths doesn't make much sense on Unix systems, but this does reflect the behavior of node on Linux at least...
	return (ffi.os == "Windows") and cwd:sub(1, 2) or ""
end

local windowsTestCases = {
	-- Arguments                               result
	{ { "c:/blah\\blah", "d:/games", "c:../a" }, "c:\\blah\\a" },
	{ { "c:/ignore", "d:\\a/b\\c/d", "\\e.exe" }, "d:\\e.exe" }, -- d is the last drive visited, so stay on there. network paths do not change the current drive
	{ { "c:/ignore", "c:/some/file" }, "c:\\some\\file" }, -- cd in same drive means the second command overrides the first
	{ { "d:/ignore", "d:some/dir//" }, "d:\\ignore\\some\\dir" }, -- d: is invalid drive identifier, so it should be skipped
	{ { "." }, windowsCwd }, -- cwd is resolved properly
	{ { "//server/share", "..", "relative\\" }, "\\\\server\\share\\relative" },
	{ { "c:/", "//" }, "c:\\" },
	{ { "c:/", "//dir" }, "c:\\dir" },
	{ { "c:/", "//server/share" }, "\\\\server\\share\\" },
	{ { "c:/", "//server//share" }, "\\\\server\\share\\" },
	{ { "c:/", "///some//dir" }, "c:\\some\\dir" },
	{ { "C:\\foo\\tmp.3\\", "..\\tmp.3\\cycles\\root.js" }, "C:\\foo\\tmp.3\\cycles\\root.js" },
	-- Custom tests (since the NodeJS ones don't seem to exercise all code paths, for some reason)
	{ { "ignore/dir" }, windowsCwd .. "\\ignore\\dir" }, -- relative path resolution should use the current drive's cwd
	{ { "ignore", "", "/dir" }, getCurrentDeviceRoot() .. "\\dir" }, -- empty path segments should be ignored
}

local posixTestCases = {
	-- Arguments                    result
	{ { "/var/lib", "../", "file/" }, "/var/file" },
	{ { "/var/lib", "/../", "file/" }, "/file" },
	{ { "a/b/c/", "../../.." }, posixyCwd },
	{ { "." }, posixyCwd },
	{ { "/some/dir", ".", "/absolute/" }, "/absolute" },
	{ { "ignore", "", "/dir" }, "/dir" }, -- empty path segments should be ignored
	{ { "/foo/tmp.3/", "../tmp.3/cycles/root.js" }, "/foo/tmp.3/cycles/root.js" },
}

for index, testCase in ipairs(windowsTestCases) do
	local expected = testCase[2]
	local inputs = testCase[1]

	-- The behaviour should be identical for both Windows and POSIX systems
	local actual = path.win32.resolve(unpack(inputs))
	assertEquals(actual, expected, index)
end

for index, testCase in ipairs(posixTestCases) do
	local expected = testCase[2]
	local inputs = testCase[1]

	local actual = path.posix.resolve(unpack(inputs))
	assertEquals(actual, expected, index)
end

-- Resolve, internally ignores all the zero-length strings and returns the
-- current working directory
local pwd = uv.cwd()
assertEquals(path.resolve(""), pwd)
assertEquals(path.resolve("", ""), pwd)
