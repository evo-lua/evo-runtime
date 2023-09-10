local ffi = require("ffi")
local iconv = require("iconv")

describe("iconv", function()
	describe("bindings", function()
		describe("decode_multibyte_string", function()
			it("should return zero if the conversation failed with an error", function()
				local inputBuffer = buffer.new()
				local outputBuffer = buffer.new(1024)
				local ptr, len = outputBuffer:reserve(1024)
				local numBytesWritten = iconv.bindings.iconv_convert(inputBuffer, "CP949", "UTF-8", ptr, len)

				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should be able to convert Windows encodings to UTF-8", function()
				local inputBuffer = ffi.new("char[15]", "\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA\000")
				local outputBuffer = buffer.new(1024)
				local ptr, len = outputBuffer:reserve(1024)
				assertEquals(len, 1024)
				local numBytesWritten = iconv.bindings.iconv_convert(inputBuffer, "CP949", "UTF-8", ptr, len)
				outputBuffer:commit(numBytesWritten)

				assertEquals(tostring(outputBuffer), "유저인터페이스")
				assertEquals(tonumber(numBytesWritten), 21)
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
	end)
end)
