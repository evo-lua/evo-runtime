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
			assertEquals(vfs.dlname("foo"), isWindows and "libfoo.dll" or "libfoo.so")
		end)
	end)

	describe("dlopen", function()
		it("should throw if an invalid library name was passed", function()
			assertThrows(function()
				vfs.dlopen({}, nil)
			end, "Expected argument libraryName to be a string value, but received a nil value instead")
		end)
	end)

	local uv = require("uv")
	local directoryTreeBefore = C_FileSystem.ReadDirectory(uv.cwd())

	local tmpDirPath = uv.fs_mkdtemp("VFS-DLOPEN-TEST-XXXXXX")
	local appDir = path.join(tmpDirPath, "vfs-dlopen-test-app")
	local libName = "libdlopen.so"
	local inputFilePath = path.join("Tests", "Fixtures", "dlopen.c")
	local sharedLibraryPath = path.join(appDir, libName) -- TBD win32 = dlopen.dll
	C_FileSystem.MakeDirectory(appDir)

	-- Not exactly the height of portability, but it matches the assumptions made by the build system
	local dlibBuildCommand = format("gcc -shared %s -o %s", inputFilePath, sharedLibraryPath)
	assert(os.execute(dlibBuildCommand))
	assertTrue(C_FileSystem.Exists(sharedLibraryPath))

	-- TODO this should likely be an integration test?
	local appMainPath = path.join(appDir, "main.lua")
	local scriptCode = format(
		[[
		local vfs = require("vfs")
		local lib = vfs.dlopen("%s")
		local result = lib.vfs_dlopen_test(42)
		assert(result == 42, result)
		]],
		libName
	)
	C_FileSystem.WriteFile(appMainPath, scriptCode)

	-- Attempting to ffi.load this should always trigger an error
	local fakeLibraryPath = appMainPath .. ".so"
	C_FileSystem.WriteFile(fakeLibraryPath, scriptCode)

	local evo = require("evo") -- Very hacky. Can find a cleaner way?
	evo.buildZipApp("build", { appDir })
	-- TODO vfs.decode should not be needed, OR store zip app in runtime.vfs and default to using that if first arg is nil - maybe swap args so 2nd is optional?
	describe("dlopen", function()
		local appBytes = C_FileSystem.ReadFile(path.basename(appDir)) -- TBD .exe for win32, exeName var
		local zipApp = vfs.decode(appBytes)

		it("should fail if no library with the given name exists in the archive", function()
			assertFailure(function()
				return vfs.dlopen(zipApp, "does-not-exist.so")
			end, "Failed to extract file does-not-exist.so (no such entry exists)")
		end)

		it("should fail if the given file path is not a valid object file", function()
			assertFailure(function()
				return vfs.dlopen(zipApp, "main.lua.so")
			end) -- Error message will be platform-dependent, so don't hardcode it here
		end)

		it("should be able to determine the platform-specific file extension", function()
			assertFailure(function()
				-- File doesn't exist (expected), but the name should be resolved anyway
				return vfs.dlopen(zipApp, "invalid")
			end, format("Failed to extract file %s (no such entry exists)", vfs.dlname("invalid")))
		end)

		it("should be able to load dynamic libraries that exist in the archive", function()
			local lib = vfs.dlopen(zipApp, libName)

			local cdefs = [[
				uint32_t vfs_dlopen_test(uint32_t input);
				]]
			local ffi = require("ffi")
			ffi.cdef(cdefs)

			local result = lib.vfs_dlopen_test(42) -- TBD allow loading cdefs from VFS (automatically? -> new issue)
			assertEquals(result, 42 * 2)
		end)
	end)

	assert(C_FileSystem.Delete(path.basename(appDir))) -- TBD win32 .. ".exe"))
	assert(C_FileSystem.Delete(path.basename(appDir) .. ".zip")) -- TBD win32 .. ".exe"))
	assert(C_FileSystem.Delete(appMainPath))
	assert(C_FileSystem.Delete(fakeLibraryPath))
	assert(C_FileSystem.Delete(sharedLibraryPath))
	assert(C_FileSystem.Delete(appDir))
	assert(C_FileSystem.Delete(tmpDirPath))

	local directoryTreeAfter = C_FileSystem.ReadDirectory(uv.cwd())
	assertEquals(directoryTreeBefore, directoryTreeAfter)
end)
