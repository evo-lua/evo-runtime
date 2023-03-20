local path = require("path")

local posixTestCases = {
	-- Arguments                     result
	{ { ".", "x/b", "..", "/b/c.js" }, "x/b/c.js" },
	{ {}, "." },
	{ { "/.", "x/b", "..", "/b/c.js" }, "/x/b/c.js" },
	{ { "/foo", "../../../bar" }, "/bar" },
	{ { "foo", "../../../bar" }, "../../bar" },
	{ { "foo/", "../../../bar" }, "../../bar" },
	{ { "foo/x", "../../../bar" }, "../bar" },
	{ { "foo/x", "./bar" }, "foo/x/bar" },
	{ { "foo/x/", "./bar" }, "foo/x/bar" },
	{ { "foo/x/", ".", "bar" }, "foo/x/bar" },
	{ { "./" }, "./" },
	{ { ".", "./" }, "./" },
	{ { ".", ".", "." }, "." },
	{ { ".", "./", "." }, "." },
	{ { ".", "/./", "." }, "." },
	{ { ".", "/////./", "." }, "." },
	{ { "." }, "." },
	{ { "", "." }, "." },
	{ { "", "foo" }, "foo" },
	{ { "foo", "/bar" }, "foo/bar" },
	{ { "", "/foo" }, "/foo" },
	{ { "", "", "/foo" }, "/foo" },
	{ { "", "", "foo" }, "foo" },
	{ { "foo", "" }, "foo" },
	{ { "foo/", "" }, "foo/" },
	{ { "foo", "", "/bar" }, "foo/bar" },
	{ { "./", "..", "/foo" }, "../foo" },
	{ { "./", "..", "..", "/foo" }, "../../foo" },
	{ { ".", "..", "..", "/foo" }, "../../foo" },
	{ { "", "..", "..", "/foo" }, "../../foo" },
	{ { "/" }, "/" },
	{ { "/", "." }, "/" },
	{ { "/", ".." }, "/" },
	{ { "/", "..", ".." }, "/" },
	{ { "" }, "." },
	{ { "", "" }, "." },
	{ { " /foo" }, " /foo" },
	{ { " ", "foo" }, " /foo" },
	{ { " ", "." }, " " },
	{ { " ", "/" }, " /" },
	{ { " ", "" }, " " },
	{ { "/", "foo" }, "/foo" },
	{ { "/", "/foo" }, "/foo" },
	{ { "/", "//foo" }, "/foo" },
	{ { "/", "", "/foo" }, "/foo" },
	{ { "", "/", "foo" }, "/foo" },
	{ { "", "/", "/foo" }, "/foo" },
}

local windowsTestCases = { -- Arguments                     result
	-- UNC path expected
	{ { "//foo/bar" }, "\\\\foo\\bar\\" },
	{ { "\\/foo/bar" }, "\\\\foo\\bar\\" },
	{ { "\\\\foo/bar" }, "\\\\foo\\bar\\" },
	-- UNC path expected - server and share separate
	{ { "//foo", "bar" }, "\\\\foo\\bar\\" },
	{ { "//foo/", "bar" }, "\\\\foo\\bar\\" },
	{ { "//foo", "/bar" }, "\\\\foo\\bar\\" },
	-- UNC path expected - questionable
	{ { "//foo", "", "bar" }, "\\\\foo\\bar\\" },
	{ { "//foo/", "", "bar" }, "\\\\foo\\bar\\" },
	{ { "//foo/", "", "/bar" }, "\\\\foo\\bar\\" },
	-- UNC path expected - even more questionable
	{ { "", "//foo", "bar" }, "\\\\foo\\bar\\" },
	{ { "", "//foo/", "bar" }, "\\\\foo\\bar\\" },
	{ { "", "//foo/", "/bar" }, "\\\\foo\\bar\\" },
	-- No UNC path expected (no double slash in first component)
	{ { "\\", "foo/bar" }, "\\foo\\bar" },
	{ { "\\", "/foo/bar" }, "\\foo\\bar" },
	{ { "", "/", "/foo/bar" }, "\\foo\\bar" },
	-- No UNC path expected (no non-slashes in first component -
	-- questionable)
	{ { "//", "foo/bar" }, "\\foo\\bar" },
	{ { "//", "/foo/bar" }, "\\foo\\bar" },
	{ { "\\\\", "/", "/foo/bar" }, "\\foo\\bar" },
	{ { "//" }, "\\" },
	-- No UNC path expected (share name missing - questionable).
	{ { "//foo" }, "\\foo" },
	{ { "//foo/" }, "\\foo\\" },
	{ { "//foo", "/" }, "\\foo\\" },
	{ { "//foo", "", "/" }, "\\foo\\" },
	-- No UNC path expected (too many leading slashes - questionable)
	{ { "///foo/bar" }, "\\foo\\bar" },
	{ { "////foo", "bar" }, "\\foo\\bar" },
	{ { "\\\\\\/foo/bar" }, "\\foo\\bar" },
	-- Drive-relative vs drive-absolute paths. This merely describes the
	-- status quo, rather than being obviously right
	{ { "c:" }, "c:." },
	{ { "c:." }, "c:." },
	{ { "c:", "" }, "c:." },
	{ { "", "c:" }, "c:." },
	{ { "c:.", "/" }, "c:.\\" },
	{ { "c:.", "file" }, "c:file" },
	{ { "c:", "/" }, "c:\\" },
	{ { "c:", "file" }, "c:\\file" },
}

for index, testCase in ipairs(windowsTestCases) do
	local expected = testCase[2]
	local inputs = testCase[1]

	local actual = path.win32.join(unpack(inputs))
	assertEquals(actual, expected, index)
end

for index, testCase in ipairs(posixTestCases) do
	local expected = testCase[2]
	local inputs = testCase[1]

	local actual = path.posix.join(unpack(inputs))
	assertEquals(actual, expected, index)
end

-- Join will internally ignore all the zero-length strings and it will return
-- '.' if the joined string is a zero-length string.
local uv = require("uv")
local pwd = uv.cwd()
assertEquals(path.posix.join(""), ".")
assertEquals(path.posix.join("", ""), ".")
assertEquals(path.win32.join(""), ".")
assertEquals(path.win32.join("", ""), ".")
assertEquals(path.join(pwd), pwd)
assertEquals(path.join(pwd, ""), pwd)
