describe("miniz", function()
	local miniz = require("miniz")
	local exportedFunctions = {
		"version",
		"new_reader",
		"new_writer",
		"inflate",
		"deflate",
		"adler32",
		"crc32",
		"compress",
		"uncompress",
		"new_deflator",
		"new_inflator",
	}

	it("should export all miniz functions", function()
		for _, functionName in ipairs(exportedFunctions) do
			local exportedFunction = miniz[functionName]
			assertEquals(type(exportedFunction), "function", "Should export function " .. functionName)
		end
	end)

	describe("version", function()
		it("should return the embedded miniz version in semver format", function()
			local embeddedMinizVersion = miniz.version()
			local firstMatchedCharacterIndex, lastMatchedCharacterIndex =
				string.find(embeddedMinizVersion, "%d+.%d+.%d+")

			assertEquals(firstMatchedCharacterIndex, 1)
			assertEquals(lastMatchedCharacterIndex, string.len(embeddedMinizVersion))
			assertEquals(type(string.match(embeddedMinizVersion, "%d+.%d+.%d+")), "string")
		end)
	end)

	describe("deflate", function()
		it("should return a compressed buffer for the given input string", function()
			local compressedString = miniz.deflate("Hello world")
			assertEquals(compressedString, "\x01\x0B\x00\xF4\xFF\x48\x65\x6C\x6C\x6F\x20\x77\x6F\x72\x6C\x64")
		end)
	end)

	describe("inflate", function()
		it("should return a decompressed buffer for the given input string", function()
			local decompressedString = miniz.inflate("\x01\x0B\x00\xF4\xFF\x48\x65\x6C\x6C\x6F\x20\x77\x6F\x72\x6C\x64")
			assertEquals(decompressedString, "Hello world")
		end)
	end)

	describe("adler32", function()
		it("should return a checksum for the given input string", function()
			local checksum = miniz.adler32(1, "Hello world")
			assertEquals(checksum, 413860925)
		end)

		it("should generate the same checksum regardless of how it is computed", function()
			local checksum1 = miniz.adler32(1, "one two")
			assertEquals(checksum1, 181797565)

			local checksum2 = miniz.adler32(1, "one")
			checksum2 = miniz.adler32(checksum2, " two")

			assertEquals(checksum1, checksum2)
		end)
	end)

	describe("crc32", function()
		it("should return a checksum for the given input string", function()
			local checksum = miniz.crc32(0, "Hello world")
			assertEquals(checksum, 2346098258)
		end)

		it("should generate the same checksum regardless of how it is computed", function()
			local checksum1 = miniz.crc32(0, "one two")
			assertEquals(checksum1, 3439823151)

			local checksum2 = miniz.crc32(0, "one")
			checksum2 = miniz.crc32(checksum2, " two")

			assertEquals(checksum1, checksum2)
		end)
	end)

	-- Adapted test cases from luvi's examples
	local MINIZ_EXAMPLE_TEXT_FILE = path.join("Tests", "Fixtures", "miniz-poem.txt")
	local MINIZ_EXAMPLE_ZIP_FILE = path.join("Tests", "Fixtures", "miniz-poem.zip")
	local MINIZ_EXAMPLE_TEXT = C_FileSystem.ReadFile(MINIZ_EXAMPLE_TEXT_FILE)
	describe("uncompress", function()
		it("should return the original text when given a valid buffer of compressed data", function()
			local original = string.rep(MINIZ_EXAMPLE_TEXT, 1000)
			local compressed = assert(miniz.compress(original))
			local uncompressed = assert(miniz.uncompress(compressed, #original))
			assertEquals(uncompressed, original)
		end)
	end)

	describe("new_inflator", function()
		it("should return a function that is able to correctly decompress the input in chunks", function()
			local original_parts = {}
			for part in MINIZ_EXAMPLE_TEXT:gmatch((".?"):rep(64)) do
				original_parts[#original_parts + 1] = part
			end

			local compressionLevel = 9
			local deflator = miniz.new_deflator(compressionLevel)
			local inflator = miniz.new_inflator()

			for i, part in ipairs(original_parts) do
				local inflated, deflated, err, partial
				deflated, err, partial = deflator:deflate(part, i == #original_parts and "finish" or "sync")
				deflated = assert(not err, err) and (deflated or partial)

				inflated, err, partial = inflator:inflate(deflated, i == #original_parts and "finish" or "sync")
				inflated = assert(not err, err) and (inflated or partial)

				assertEquals(inflated, part)
			end
		end)

		it("should return a function that is able to correctly decompress the input as a whole", function()
			local original = string.rep(MINIZ_EXAMPLE_TEXT, 1000)
			local compressionLevel = 9
			local deflator = miniz.new_deflator(compressionLevel)

			local inflated, deflated, err, _
			deflated, err, _ = deflator:deflate(original, "finish")

			deflated = assert(deflated, err)
			local inflator = miniz.new_inflator()
			inflated, err, _ = inflator:inflate(deflated)

			inflated = assert(inflated, err)
			assertEquals(inflated, original)
		end)
	end)

	describe("new_writer", function()
		it("should return a function that can add files from an existing zip file to a new archive", function()
			local writer = miniz.new_writer()

			local reader = miniz.new_reader(MINIZ_EXAMPLE_ZIP_FILE)
			local offset = reader:get_offset()
			assertEquals(offset, 0) -- Basic sanity check

			for i = 1, reader:get_num_files() do
				writer:add_from_zip(reader, i)
			end

			local zipFileContents = writer:finalize()
			assertEquals(#zipFileContents, 844)
		end)

		it("should return a function that can write files to a new zip archive", function()
			local writer = miniz.new_writer()

			local reader = miniz.new_reader(MINIZ_EXAMPLE_ZIP_FILE)
			local offset = reader:get_offset()
			assertEquals(offset, 0) -- Basic sanity check

			writer:add("README.md", "# A Readme\n\nThis is ~~neat?~~ Sparta!", 9)
			writer:add("data.json", '{"name":"Not Tim","age":32}\n', 9)
			writer:add("a/big/file.dat", string.rep("12345\n", 10000), 9)
			writer:add("main.lua", 'print("Hello world!")', 9)

			local zipFileContents = writer:finalize()
			assertEquals(#zipFileContents, 681)
		end)
	end)

	describe("new_reader", function()
		it("should fail if an invalid file path was passed", function()
			assertFailure(
				function()
					return miniz.new_reader("asdf-does-not-exist.zip")
				end,
				"Failed to initialize miniz reader for archive asdf-does-not-exist.zip (Last error: failed finding central directory)"
			)
		end)
	end)
end)
