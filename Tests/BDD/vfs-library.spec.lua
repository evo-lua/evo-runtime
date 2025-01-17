local ffi = require("ffi")
local vfs = require("vfs")

describe("vfs", function()
	describe("decode", function()
		it("should fail if an invalid input type was passed", function()
			assertThrows(function()
				vfs.decode(nil)
			end, "Expected argument fileContents to be a string value, but received a nil value instead")
		end)

		it("should fail if the given file is too small to be a valid LUAZIP file", function()
			assertFailure(function()
				local fileContents = C_FileSystem.ReadFile(path.join("Tests", "Fixtures", "empty.txt"))
				return vfs.decode(fileContents)
			end, "Failed to decode LUAZIP buffer (input size is too small)")
		end)

		it("should fail if the given file isn't a valid LUAZIP file", function()
			assertFailure(function()
				local fileContents = C_FileSystem.ReadFile(path.join("Tests", "Fixtures", "miniz-poem.zip"))
				return vfs.decode(fileContents)
			end, "Failed to decode LUAZIP buffer (magic value is missing)")
		end)

		it("should be able to read a valid LUAZIP file (version 1.0)", function()
			local fileContents = C_FileSystem.ReadFile(path.join("Tests", "Fixtures", "hello-world-app.bin"))
			local zipApp = vfs.decode(fileContents)

			assertEquals(zipApp.signature.magicValue, "LUAZIP")
			assertEquals(zipApp.signature.versionMajor, 1)
			assertEquals(zipApp.signature.versionMinor, 0)
			assertEquals(zipApp.signature.executableSize, 5)
			assertEquals(zipApp.signature.archiveSize, 471)

			local expectedExecutableBytes = "asdf!"
			assertEquals(#zipApp.executable, #expectedExecutableBytes)
			assertEquals(zipApp.executable, expectedExecutableBytes)

			local expectedArchiveBytes = C_FileSystem.ReadFile(path.join("Tests", "Fixtures", "hello-world-app.zip"))
			assertEquals(#zipApp.archive, #expectedArchiveBytes)
			assertEquals(zipApp.archive, expectedArchiveBytes)
		end)
	end)

	describe("dofile", function()
		local fileContents = C_FileSystem.ReadFile(path.join("Tests", "Fixtures", "hello-world-app.bin"))
		local zipApp = assert(vfs.decode(fileContents))

		it("should throw if an invalid zip app was passed", function()
			assertThrows(function()
				vfs.dofile(nil, nil)
			end, "Expected argument zipApp to be a table value, but received a nil value instead")
		end)

		it("should throw if an invalid file path was passed", function()
			assertThrows(function()
				vfs.dofile(zipApp, nil)
			end, "Expected argument filePath to be a string value, but received a nil value instead")
		end)

		it("should throw if the given file doesn't exist within the archive", function()
			assertFailure(function()
				return vfs.dofile(zipApp, "this-file-does-not-exist")
			end, "Failed to load file this-file-does-not-exist (no such entry exists)")
		end)

		it("should execute the file contents as a Lua chunk and return the result", function()
			assertEquals(vfs.dofile(zipApp, path.win32.join("subdirectory", "another-file.lua")), 42)
		end)
	end)

	describe("extract", function()
		local fileContents = C_FileSystem.ReadFile(path.join("Tests", "Fixtures", "hello-world-app.bin"))
		local zipApp = assert(vfs.decode(fileContents))

		it("should throw if an invalid zip app was passed", function()
			assertThrows(function()
				vfs.extract(nil, nil)
			end, "Expected argument zipApp to be a table value, but received a nil value instead")
		end)

		it("should throw if an invalid file path was passed", function()
			assertThrows(function()
				vfs.extract(zipApp, nil)
			end, "Expected argument filePath to be a string value, but received a nil value instead")
		end)

		it("should throw if the given file doesn't exist within the archive", function()
			assertFailure(function()
				return vfs.extract(zipApp, "this-file-does-not-exist")
			end, "Failed to extract file this-file-does-not-exist (no such entry exists)")
		end)

		it("should return the decompressed file contents", function()
			local filePath = path.join("Tests", "Fixtures", "hello-world-app", "subdirectory", "another-file.lua")
			local expectedFileContents = C_FileSystem.ReadFile(filePath)

			-- The fixture was apparently generated with different formatter settings - whatever
			expectedFileContents = expectedFileContents:gsub("\n", "")
			expectedFileContents = expectedFileContents:gsub("\r", "")

			local vfsPath = path.win32.join("subdirectory", "another-file.lua")
			assertEquals(vfs.extract(zipApp, vfsPath), expectedFileContents)
		end)
	end)

	describe("dlname", function()
		it("should throw if an invalid library name was passed", function()
			assertThrows(function()
				vfs.dlname(nil)
			end, "Expected argument libraryName to be a string value, but received a nil value instead")
		end)

		it("should return the input string if the library name indicates a Windows DLL", function()
			assertEquals(vfs.dlname("foo.dll"), "foo.dll")
			assertEquals(vfs.dlname("some/directory/foo.dll"), "some/directory/foo.dll")
		end)

		it("should return the input string if the library name indicates a shared object file", function()
			assertEquals(vfs.dlname("libfoo.so"), "libfoo.so")
			assertEquals(vfs.dlname("some/directory/libfoo.so"), "some/directory/libfoo.so")
		end)

		it("should be able to recognize valid extensions with inconsistent capitalization", function()
			assertEquals(vfs.dlname("libfoo.SO"), "libfoo.SO")
			assertEquals(vfs.dlname("foo.dLL"), "foo.dLL")
		end)

		it("should adhere to platform-specific conventions if the library name isn't fully qualified", function()
			local isWindows = ffi.os == "Windows"
			assertEquals(vfs.dlname("foo"), isWindows and "foo.dll" or "libfoo.so")
		end)
	end)

	describe("dlopen", function()
		it("should throw if an invalid library name was passed", function()
			assertThrows(function()
				vfs.dlopen({}, nil)
			end, "Expected argument libraryName to be a string value, but received a nil value instead")
		end)
	end)
end)
