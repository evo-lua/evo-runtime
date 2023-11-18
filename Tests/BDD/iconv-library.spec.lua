local ffi = require("ffi")
local iconv = require("iconv")

describe("iconv", function()
	describe("bindings", function()
		describe("iconv_convert", function()
			it("should return zero if the conversation failed with an error", function()
				local inputBuffer = buffer.new()
				local outputBuffer = buffer.new(1024)
				local ptr, len = outputBuffer:reserve(1024)
				local numBytesWritten =
					iconv.bindings.iconv_convert(inputBuffer, #inputBuffer, "CP949", "UTF-8", ptr, len)

				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should be able to convert Windows encodings to UTF-8", function()
				local inputBuffer = ffi.new("char[15]", "\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA\000")
				local outputBuffer = buffer.new(1024)
				local ptr, len = outputBuffer:reserve(1024)
				assertEquals(len, 1024)
				local numBytesWritten = iconv.bindings.iconv_convert(inputBuffer, 14, "CP949", "UTF-8", ptr, len)
				outputBuffer:commit(numBytesWritten)

				assertEquals(tostring(outputBuffer), "유저인터페이스")
				assertEquals(tonumber(numBytesWritten), 21)
			end)

			it("should be able to deal with unterminated string literals without crashing", function()
				local badInput = ffi.new("char[5]")
				badInput[0] = 65 -- 'A'
				badInput[1] = 66 -- 'B'
				badInput[2] = 67 -- 'C'
				badInput[3] = 68 -- 'D'
				badInput[4] = 69 -- 'E' (Note: No null terminator)

				local outputBuffer = buffer.new(1024)
				local ptr, len = outputBuffer:reserve(1024)

				local numBytesWritten = iconv.bindings.iconv_convert(badInput, 5, "UTF-8", "UTF-16", ptr, len)
				outputBuffer:commit(numBytesWritten)

				assertEquals(tonumber(numBytesWritten), 12)
			end)
		end)
	end)

	describe("convert", function()
		it("should be able to convert Windows encodings to UTF-8", function()
			local input = "\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA"
			local output, numBytesWritten = iconv.convert(input, "CP949", "UTF-8")

			assertEquals(output, "유저인터페이스")
			assertEquals(numBytesWritten, 21)
		end)

		it("should fail gracefully if an empty string was passed", function()
			-- Bare minimum: Must not segfault here
			local input = ""
			local output, numBytesWritten = iconv.convert(input, "CP949", "UTF-8")

			assertEquals(output, "")
			assertEquals(numBytesWritten, 0)
		end)

		it("should fail gracefully if given the wrong input encoding", function()
			local input = "유저인터페이스"
			local output, numBytesWritten = iconv.convert(input, "CP949", "UTF-8")

			assertEquals(output, "")
			assertEquals(numBytesWritten, 0)
		end)

		it("should fail gracefully if given an invalid input encoding", function()
			local input = "유저인터페이스"
			local output, numBytesWritten = iconv.convert(input, "INVALID_ENCODING", "UTF-8")

			assertEquals(output, "")
			assertEquals(numBytesWritten, 0)
		end)

		it("should fail gracefully if given an invalid output encoding", function()
			local input = "유저인터페이스"
			local output, numBytesWritten = iconv.convert(input, "UTF-8", "INVALID_ENCODING")

			assertEquals(output, "")
			assertEquals(numBytesWritten, 0)
		end)
	end)
end)
