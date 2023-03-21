local uv = require("uv")

local validFilePath = path.join(uv.cwd(), "Tests", "Fixtures", "empty.txt")
local validDirectoryPath = path.join(uv.cwd(), "Tests", "Fixtures", "DirectoryWithSubdirectories")
local invalidPath = "invalid-does-not-exist.asdf"

describe("C_FileSystem", function()
	describe("Exists", function()
		it("should return true if the given path refers to a file on disk", function()
			assertTrue(C_FileSystem.Exists(validFilePath))
		end)

		it("should return true if the given path refers to a directory on disk", function()
			assertTrue(C_FileSystem.Exists(validDirectoryPath))
		end)

		it("should return false if the given path refers to neither a file nor a directory", function()
			assertFalse(C_FileSystem.Exists(invalidPath))
		end)
	end)

	describe("IsFile", function()
		it("should return true if the given path refers to a file on disk", function()
			assertTrue(C_FileSystem.IsFile(validFilePath))
		end)

		it("should return false if the given path refers to a directory on disk", function()
			assertFalse(C_FileSystem.IsFile(validDirectoryPath))
		end)

		it("should return false if the given path refers to neither a file nor a directory", function()
			assertFalse(C_FileSystem.IsFile(invalidPath))
		end)
	end)

	describe("IsDirectory", function()
		it("should return false if the given path refers to a file on disk", function()
			assertFalse(C_FileSystem.IsDirectory(validFilePath))
		end)

		it("should return true if the given path refers to a directory on disk", function()
			assertTrue(C_FileSystem.IsDirectory(validDirectoryPath))
		end)

		it("should return false if the given path refers to neither a file nor a directory", function()
			assertFalse(C_FileSystem.IsDirectory(invalidPath))
		end)
	end)

	describe("MakeDirectory", function()
		it("should return false if the given path refers to an existing file on disk", function()
			assertFalse(C_FileSystem.MakeDirectory(validFilePath))
		end)

		it("should return false if the given path refers to an existing directory on disk", function()
			assertFalse(C_FileSystem.MakeDirectory(validDirectoryPath))
		end)

		it("should return true if the directory has been successfully created", function()
			assertTrue(C_FileSystem.MakeDirectory("something"))
			assertTrue(C_FileSystem.Delete("something"))
		end)
	end)

	describe("Delete", function()
		local tempFilePath = "temp.txt"
		local tempDirPath = "temp"

		before(function()
			assertTrue(C_FileSystem.WriteFile(tempFilePath, "hello"))
			assertTrue(C_FileSystem.MakeDirectory(tempDirPath))
		end)

		after(function()
			assertTrue(C_FileSystem.Delete(tempFilePath))
			assertTrue(C_FileSystem.Delete(tempDirPath))
		end)

		it("should return true if the given path refers to a file on disk", function()
			assertTrue(C_FileSystem.Exists(tempFilePath))

			assertTrue(C_FileSystem.Delete(tempFilePath))
			assertFalse(C_FileSystem.Exists(tempFilePath))
		end)

		it("should return true if the given path refers to a directory on disk", function()
			assertTrue(C_FileSystem.Exists(tempDirPath))

			assertTrue(C_FileSystem.Delete(tempDirPath))
			assertFalse(C_FileSystem.Exists(tempDirPath))
		end)

		it("should return true if the given path refers to neither a file nor a directory", function()
			assertTrue(C_FileSystem.Delete(invalidPath))
		end)
	end)

	describe("ReadDirectory", function()
		it("should raise an error if the path given refers to a file on disk", function()
			assertThrows(function()
				C_FileSystem.ReadDirectory(validFilePath)
			end, "ENOTDIR: not a directory: " .. validFilePath)
		end)

		it("should raise an error if an invalid path was passed", function()
			assertThrows(function()
				C_FileSystem.ReadDirectory(invalidPath)
			end, "ENOENT: no such file or directory: " .. invalidPath)
		end)

		it(
			"should return the absolute paths of files in all subdirectories if the isRecursiveMode flag is set to true",
			function()
				local contents = C_FileSystem.ReadDirectory(validDirectoryPath, true)
				assertEquals(contents, {
					[path.join(validDirectoryPath, "empty.txt")] = true,
					[path.join(validDirectoryPath, "somefile.txt")] = true,
					[path.join(validDirectoryPath, "Subdir1", "Subdir2", "hello.txt")] = true,
					[path.join(validDirectoryPath, "Subdir1", "test.txt")] = true,
				})
			end
		)

		it(
			"should return the relative paths of files in the root directory if the isRecursiveMode flag is set to false",
			function()
				local contents = C_FileSystem.ReadDirectory(validDirectoryPath, false)
				assertEquals(contents, {
					["empty.txt"] = true,
					["somefile.txt"] = true,
					["Subdir1"] = true,
				})
			end
		)

		it(
			"should return the relative paths of files in the root directory if the isRecursiveMode flag is omitted",
			function()
				local contents = C_FileSystem.ReadDirectory(validDirectoryPath)
				assertEquals(contents, {
					["empty.txt"] = true,
					["somefile.txt"] = true,
					["Subdir1"] = true,
				})
			end
		)
	end)

	describe("ReadFile", function()
		local tempFilePath = "temp.txt"
		before(function()
			assert(C_FileSystem.WriteFile(tempFilePath, "hello"))
		end)

		after(function()
			assertTrue(C_FileSystem.Delete(tempFilePath))
		end)

		it("should return the file contents if the path given refers to a file on disk", function()
			assertEquals(C_FileSystem.ReadFile(tempFilePath), "hello")
		end)

		it("should raise an error if the given path refers to a directory", function()
			local fixturesDir = path.join(uv.cwd(), "Tests", "Fixtures")
			assertThrows(function()
				C_FileSystem.ReadFile(fixturesDir)
			end, "EISDIR: illegal operation on a directory")
		end)

		it("should raise an error if the given path is invalid", function()
			local fixturesDir = path.join("asdf.xyz")
			assertThrows(function()
				C_FileSystem.ReadFile(fixturesDir)
			end, "ENOENT: no such file or directory: asdf.xyz")
		end)
	end)

	describe("WriteFile", function()
		it("should return true after writing successfully if the given path doesn't yet exist", function()
			assertTrue(C_FileSystem.WriteFile("newfile1.txt", "hi"))
			assertEquals(C_FileSystem.ReadFile("newfile1.txt"), "hi")
			assertTrue(C_FileSystem.Delete("newfile1.txt"))
		end)

		it("should raise an error if the given path refers to an existing directory on disk", function()
			assertThrows(function()
				C_FileSystem.WriteFile(validDirectoryPath)
			end, "EISDIR: illegal operation on a directory: " .. validDirectoryPath)
		end)
	end)

	describe("AppendFile", function()
		it("should return true after writing successfully if the given path doesn't yet exist", function()
			assertTrue(C_FileSystem.AppendFile("newfile2.txt", "asdf"))
			assertEquals(C_FileSystem.ReadFile("newfile2.txt"), "asdf")
			assertTrue(C_FileSystem.Delete("newfile2.txt"))
		end)

		it(
			"should return true after writing successfully if the given path refers to an existing file on disk",
			function()
				assertTrue(C_FileSystem.AppendFile("newfile3.txt", "hello"))
				assertEquals(C_FileSystem.ReadFile("newfile3.txt"), "hello")
				assertTrue(C_FileSystem.AppendFile("newfile3.txt", " world"))
				assertEquals(C_FileSystem.ReadFile("newfile3.txt"), "hello world")
				assertTrue(C_FileSystem.AppendFile("newfile3.txt", "!"))
				assertEquals(C_FileSystem.ReadFile("newfile3.txt"), "hello world!")
				assertTrue(C_FileSystem.Delete("newfile3.txt"))
			end
		)

		it("should raise an error if the given path refers to an existing directory on disk", function()
			assertThrows(function()
				C_FileSystem.WriteFile(validDirectoryPath)
			end, "EISDIR: illegal operation on a directory: " .. validDirectoryPath)
		end)
	end)
end)
