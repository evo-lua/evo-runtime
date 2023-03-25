local zlib = require("zlib")

describe("zlib", function()
	describe("version", function()
		it("should return the zlib version as number values", function()
			local major, minor, patch = zlib.version()
			assertEquals(type(major), "number")
			assertEquals(type(minor), "number")
			assertEquals(type(patch), "number")
		end)
	end)

	describe("deflate", function()
		it("should return a stream compression function", function()
			local streamCompressionFunction = zlib.deflate()
			assertEquals(type(streamCompressionFunction), "function")
		end)
	end)

	describe("inflate", function()
		it("should return a stream decompression function", function()
			local streamDecompressionFunction = zlib.inflate()
			assertEquals(type(streamDecompressionFunction), "function")
		end)
	end)

	describe("adler32", function()
		it("should return a checksum computation function", function()
			local checksumComputationFunction = zlib.adler32()
			assertEquals(type(checksumComputationFunction), "function")
		end)
	end)

	describe("crc32", function()
		it("should return a checksum computation function", function()
			local checksumComputationFunction = zlib.crc32()
			assertEquals(type(checksumComputationFunction), "function")
		end)

		it("should generate the same checksum regardless of how it is computed", function()
			-- All in one call:
			local checksum = zlib.crc32()("one two")
			assertEquals(checksum, 3439823151)

			-- Multiple calls:
			local compute = zlib.crc32()
			compute("one")
			assertEquals(checksum, compute(" two"))

			-- Multiple compute_checksums joined:
			local compute1, compute2 = zlib.crc32(), zlib.crc32()
			compute1("one")
			compute2(" two")
			assertEquals(checksum, compute1(compute2))
		end)
	end)
end)
