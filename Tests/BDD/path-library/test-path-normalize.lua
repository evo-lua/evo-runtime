local uv = require("uv")
local pwd = uv.cwd()

local path = require("path")

assertEquals(path.win32.normalize("./fixtures///b/../b/c.js"), "fixtures\\b\\c.js")
assertEquals(path.win32.normalize("/foo/../../../bar"), "\\bar")
assertEquals(path.win32.normalize("a//b//../b"), "a\\b")
assertEquals(path.win32.normalize("a//b//./c"), "a\\b\\c")
assertEquals(path.win32.normalize("a//b//."), "a\\b")
assertEquals(path.win32.normalize("//server/share/dir/file.ext"), "\\\\server\\share\\dir\\file.ext")
assertEquals(path.win32.normalize("/a/b/c/../../../x/y/z"), "\\x\\y\\z")
assertEquals(path.win32.normalize("C:"), "C:.")
assertEquals(path.win32.normalize("C:..\\abc"), "C:..\\abc")
assertEquals(path.win32.normalize("C:..\\..\\abc\\..\\def"), "C:..\\..\\def")
assertEquals(path.win32.normalize("C:\\."), "C:\\")
assertEquals(path.win32.normalize("file:stream"), "file:stream")
assertEquals(path.win32.normalize("bar\\foo..\\..\\"), "bar\\")
assertEquals(path.win32.normalize("bar\\foo..\\.."), "bar")
assertEquals(path.win32.normalize("bar\\foo..\\..\\baz"), "bar\\baz")
assertEquals(path.win32.normalize("bar\\foo..\\"), "bar\\foo..\\")
assertEquals(path.win32.normalize("bar\\foo.."), "bar\\foo..")
assertEquals(path.win32.normalize("..\\foo..\\..\\..\\bar"), "..\\..\\bar")
assertEquals(path.win32.normalize("..\\...\\..\\.\\...\\..\\..\\bar"), "..\\..\\bar")
assertEquals(path.win32.normalize("../../../foo/../../../bar"), "..\\..\\..\\..\\..\\bar")
assertEquals(path.win32.normalize("../../../foo/../../../bar/../../"), "..\\..\\..\\..\\..\\..\\")
assertEquals(path.win32.normalize("../foobar/barfoo/foo/../../../bar/../../"), "..\\..\\")
assertEquals(path.win32.normalize("../.../../foobar/../../../bar/../../baz"), "..\\..\\..\\..\\baz")
assertEquals(path.win32.normalize("foo/bar\\baz"), "foo\\bar\\baz")

assertEquals(path.posix.normalize("./fixtures///b/../b/c.js"), "fixtures/b/c.js")
assertEquals(path.posix.normalize("/foo/../../../bar"), "/bar")
assertEquals(path.posix.normalize("a//b//../b"), "a/b")
assertEquals(path.posix.normalize("a//b//./c"), "a/b/c")
assertEquals(path.posix.normalize("a//b//."), "a/b")
assertEquals(path.posix.normalize("/a/b/c/../../../x/y/z"), "/x/y/z")
assertEquals(path.posix.normalize("///..//./foo/.//bar"), "/foo/bar")
assertEquals(path.posix.normalize("bar/foo../../"), "bar/")
assertEquals(path.posix.normalize("bar/foo../.."), "bar")
assertEquals(path.posix.normalize("bar/foo../../baz"), "bar/baz")
assertEquals(path.posix.normalize("bar/foo../"), "bar/foo../")
assertEquals(path.posix.normalize("bar/foo.."), "bar/foo..")
assertEquals(path.posix.normalize("../foo../../../bar"), "../../bar")
assertEquals(path.posix.normalize("../.../.././.../../../bar"), "../../bar")
assertEquals(path.posix.normalize("../../../foo/../../../bar"), "../../../../../bar")
assertEquals(path.posix.normalize("../../../foo/../../../bar/../../"), "../../../../../../")
assertEquals(path.posix.normalize("../foobar/barfoo/foo/../../../bar/../../"), "../../")
assertEquals(path.posix.normalize("../.../../foobar/../../../bar/../../baz"), "../../../../baz")
assertEquals(path.posix.normalize("foo/bar\\baz"), "foo/bar\\baz")

-- Normalize will return '.' if the input is a zero-length string
assertEquals(path.posix.normalize(""), ".")
assertEquals(path.win32.normalize(""), ".")
assertEquals(path.normalize(pwd), pwd)
