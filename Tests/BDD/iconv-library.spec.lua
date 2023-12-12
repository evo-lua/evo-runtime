local ffi = require("ffi")
local iconv = require("iconv")

local function ffi_strerror(errno)
	return ffi.string(ffi.C.strerror(errno))
end

local platformSpecificErrorCodes = {
	OSX = {
		EINVAL = 22,
		EILSEQ = 92,
	},
	Linux = {
		EINVAL = 22,
		EILSEQ = 84,
	},
	Windows = {
		EINVAL = 22,
		EILSEQ = 42,
	},
}
local SUCCESS = 0
local EINVAL = platformSpecificErrorCodes[ffi.os].EINVAL
local EILSEQ = platformSpecificErrorCodes[ffi.os].EILSEQ

describe("iconv", function()
	describe("bindings", function()
		describe("iconv_convert", function()
			it("should return zero if the conversation failed with an error", function()
				local inputBuffer = buffer.new()
				local outputBuffer = buffer.new(1024)
				local ptr, len = outputBuffer:reserve(1024)
				local result = iconv.bindings.iconv_convert(inputBuffer, #inputBuffer, "CP949", "UTF-8", ptr, len)
				assertEquals(tonumber(result.status_code), EINVAL)
				assertEquals(ffi.string(result.message), ffi_strerror(EINVAL))
				assertEquals(tonumber(result.num_bytes_written), 0)
			end)

			it("should be able to convert Windows encodings to UTF-8", function()
				local inputBuffer = ffi.new("char[15]", "\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA\000")
				local outputBuffer = buffer.new(1024)
				local ptr, len = outputBuffer:reserve(1024)
				assertEquals(len, 1024)
				local result = iconv.bindings.iconv_convert(inputBuffer, 14, "CP949", "UTF-8", ptr, len)
				local numBytesWritten = tonumber(result.num_bytes_written)
				outputBuffer:commit(numBytesWritten)

				assertEquals(tostring(outputBuffer), "유저인터페이스")
				assertEquals(tonumber(result.status_code), SUCCESS)
				assertEquals(ffi.string(result.message), ffi_strerror(SUCCESS))
				assertEquals(numBytesWritten, 21)
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

				local result = iconv.bindings.iconv_convert(badInput, 5, "UTF-8", "UTF-16", ptr, len)
				local numBytesWritten = tonumber(result.num_bytes_written)
				outputBuffer:commit(numBytesWritten)

				assertEquals(tonumber(result.status_code), SUCCESS)
				assertEquals(ffi.string(result.message), ffi_strerror(SUCCESS))
				assertEquals(numBytesWritten, 12)
			end)
		end)
	end)

	describe("convert", function()
		it("should be able to convert Windows encodings to UTF-8", function()
			local input = "\xC0\xAF\xC0\xFA\xC0\xCE\xC5\xCD\xC6\xE4\xC0\xCC\xBD\xBA"
			local output, message = iconv.convert(input, "CP949", "UTF-8")
			assertEquals(output, "유저인터페이스")
			assertEquals(message, ffi_strerror(SUCCESS))
		end)

		it("should fail gracefully if an empty string was passed", function()
			local input = ""
			assertFailure(function()
				return iconv.convert(input, "CP949", "UTF-8")
			end, ffi_strerror(EINVAL))
		end)

		it("should fail gracefully if given the wrong input encoding", function()
			local input = "유저인터페이스"
			assertFailure(function()
				return iconv.convert(input, "CP949", "UTF-8")
			end, ffi_strerror(EILSEQ))
		end)

		it("should fail gracefully if given an invalid input encoding", function()
			local input = "유저인터페이스"
			assertFailure(function()
				return iconv.convert(input, "INVALID_ENCODING", "UTF-8")
			end, ffi_strerror(EINVAL))
		end)

		it("should fail gracefully if given an invalid output encoding", function()
			local input = "유저인터페이스"
			assertFailure(function()
				return iconv.convert(input, "UTF-8", "INVALID_ENCODING")
			end, ffi_strerror(EINVAL))
		end)

		it("should throw if a non-string input was passed", function()
			local function convertWithInvalidInput()
				iconv.convert(42, "CP949", "UTF-8")
			end
			local expectedErrorMessage =
				"Expected argument input to be a string value, but received a number value instead"
			assertThrows(convertWithInvalidInput, expectedErrorMessage)
		end)

		it("should throw if a non-string input encoding was passed", function()
			local function convertWithInvalidInputEncoding()
				iconv.convert("Hey!", 42, "UTF-8")
			end
			local expectedErrorMessage =
				"Expected argument inputEncoding to be a string value, but received a number value instead"
			assertThrows(convertWithInvalidInputEncoding, expectedErrorMessage)
		end)

		it("should throw if a non-string output encoding was passed", function()
			local function convertWithInvalidOutputEncoding()
				iconv.convert("Hello!", "CP949", 42)
			end
			local expectedErrorMessage =
				"Expected argument outputEncoding to be a string value, but received a number value instead"
			assertThrows(convertWithInvalidOutputEncoding, expectedErrorMessage)
		end)

		it("should be able to deal with large inputs", function()
			local largeInput = string.rep("A", 1000000)
			local output, message = iconv.convert(largeInput, "UTF-8", "CP949")
			assertEquals(largeInput, output)
			assertEquals(message, ffi_strerror(SUCCESS))
		end)
	end)
end)
