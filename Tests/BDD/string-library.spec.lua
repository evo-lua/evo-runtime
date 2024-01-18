describe("string", function()
	describe("explode", function()
		it("should return an array of whitespace-delimited tokens if no delimiter was passed ", function()
			assertEquals(string.explode("hello world"), { "hello", "world" })
		end)

		it("should return an array of tokens if the given delimiter occurs in the input string", function()
			assertEquals(string.explode("hello_world", "_"), { "hello", "world" })
		end)

		it("should return the input string itself if the given delimiter doesn't occur in it", function()
			assertEquals(string.explode("hello#world", "_"), { "hello#world" })
		end)

		it("should raise an error if no input string was given", function()
			local expectedError = "Expected argument inputString to be a string value, but received a nil value instead"
			assertThrows(function()
				string.explode(nil)
			end, expectedError)
		end)

		it("should raise an error if a n invalid delimiter was given", function()
			local expectedError =
				"Expected argument delimiter to be a string value, but received a number value instead"
			assertThrows(function()
				string.explode("asdf", 42)
			end, expectedError)
		end)
	end)

	describe("filesize", function()
		it('should return "0 bytes" for negative sizes', function()
			assertEquals(string.filesize(-1), "0 bytes")
		end)

		it('should return "0 bytes" for a size of 0', function()
			assertEquals(string.filesize(0), "0 bytes")
		end)

		it("should return value in bytes when size is less than 1KB", function()
			assertEquals(string.filesize(512), "512 bytes")
		end)

		it("should return value in KB when size is between 1KB and 1MB", function()
			assertEquals(string.filesize(1024), "1 KB")
			assertEquals(string.filesize(5120), "5 KB")
		end)

		it("should return value in MB when size is between 1MB and 1GB", function()
			assertEquals(string.filesize(1048576), "1.00 MB")
			assertEquals(string.filesize(5242880), "5.00 MB")
		end)

		it("should return value in GB when size is between 1GB and 1TB", function()
			assertEquals(string.filesize(1073741824), "1.00 GB")
			assertEquals(string.filesize(5368709120), "5.00 GB")
		end)

		it("should return value in TB when size is between 1TB and 1PB", function()
			assertEquals(string.filesize(1099511627776), "1.00 TB")
			assertEquals(string.filesize(5497558138880), "5.00 TB")
		end)

		it("should return value in PB when size is between 1PB and 1EB", function()
			assertEquals(string.filesize(1125899906842624), "1.00 PB")
			assertEquals(string.filesize(5629499534213120), "5.00 PB")
		end)

		it("should return value in EB when size is between 1EB and 1ZB", function()
			assertEquals(string.filesize(1152921504606846976), "1.00 EB")
			assertEquals(string.filesize(5764607523034234880), "5.00 EB")
		end)

		it("should return value in ZB when size is between 1ZB and 1YB", function()
			assertEquals(string.filesize(1180591620717411303424), "1.00 ZB")
			assertEquals(string.filesize(5902958103587056517120), "5.00 ZB")
		end)

		it("should return value in YB when size is larger than 1YB", function()
			assertEquals(string.filesize(1208925819614629174706176), "1.00 YB")
			assertEquals(string.filesize(6044629098073145873530880), "5.00 YB")
		end)
	end)

	describe("hexdiff", function()
		it("should return a hexadecimal string representation of the difference between both inputs", function()
			function string.hexdiff(first, second)
				return string.diff(first, second)
			end
			assertEquals(string.hexdiff("Hello world", "Hello world!"), "TBD")
		end)

	end)
end)
