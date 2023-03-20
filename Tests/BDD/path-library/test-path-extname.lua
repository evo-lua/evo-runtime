local path = require("path")

local testCases = {
	{ "test-path-extname.lua", ".lua" },
	{ "", "" },
	{ "/path/to/file", "" },
	{ "/path/to/file.ext", ".ext" },
	{ "/path.to/file.ext", ".ext" },
	{ "/path.to/file", "" },
	{ "/path.to/.file", "" },
	{ "/path.to/.file.ext", ".ext" },
	{ "/path/to/f.ext", ".ext" },
	{ "/path/to/..ext", ".ext" },
	{ "/path/to/..", "" },
	{ "file", "" },
	{ "file.ext", ".ext" },
	{ ".file", "" },
	{ ".file.ext", ".ext" },
	{ "/file", "" },
	{ "/file.ext", ".ext" },
	{ "/.file", "" },
	{ "/.file.ext", ".ext" },
	{ ".path/file.ext", ".ext" },
	{ "file.ext.ext", ".ext" },
	{ "file.", "." },
	{ ".", "" },
	{ "./", "" },
	{ ".file.ext", ".ext" },
	{ ".file", "" },
	{ ".file.", "." },
	{ ".file..", "." },
	{ "..", "" },
	{ "../", "" },
	{ "..file.ext", ".ext" },
	{ "..file", ".file" },
	{ "..file.", "." },
	{ "..file..", "." },
	{ "...", "." },
	{ "...ext", ".ext" },
	{ "....", "." },
	{ "file.ext/", ".ext" },
	{ "file.ext//", ".ext" },
	{ "file/", "" },
	{ "file//", "" },
	{ "file./", "." },
	{ "file.//", "." },
}

for index, testCase in ipairs(testCases) do
	local expected = testCase[2]
	local input = testCase[1]

	-- The behaviour should be identical for both Windows and POSIX systems
	local actual = path.win32.extname(input)
	assertEquals(actual, expected, index)

	actual = path.posix.extname(input)
	assertEquals(actual, expected, index)
end

-- On Windows, backslash is a path separator.
assertEquals(path.win32.extname(".\\"), "")
assertEquals(path.win32.extname("..\\"), "")
assertEquals(path.win32.extname("file.ext\\"), ".ext")
assertEquals(path.win32.extname("file.ext\\\\"), ".ext")
assertEquals(path.win32.extname("file\\"), "")
assertEquals(path.win32.extname("file\\\\"), "")
assertEquals(path.win32.extname("file.\\"), ".")
assertEquals(path.win32.extname("file.\\\\"), ".")

-- On *nix, backslash is a valid name component like any other character.
assertEquals(path.posix.extname(".\\"), "")
assertEquals(path.posix.extname("..\\"), ".\\")
assertEquals(path.posix.extname("file.ext\\"), ".ext\\")
assertEquals(path.posix.extname("file.ext\\\\"), ".ext\\\\")
assertEquals(path.posix.extname("file\\"), "")
assertEquals(path.posix.extname("file\\\\"), "")
assertEquals(path.posix.extname("file.\\"), ".\\")
assertEquals(path.posix.extname("file.\\\\"), ".\\\\")
