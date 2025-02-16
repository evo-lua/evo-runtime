local ffi = require("ffi")
local iconv = require("iconv")

local EOF_SYMBOL = "\0"
local UTF_MAX_BYTES_PER_CODEPOINT = 4
local function assertConversionResult(options)
	local readBuffer = buffer.new(#options.input)
	readBuffer:set(options.input)
	local readCursor, inputSize = readBuffer:ref()
	assertEquals(inputSize, #options.input)

	local maxRequiredWriteBufferSize = inputSize * UTF_MAX_BYTES_PER_CODEPOINT + #EOF_SYMBOL
	local writeBuffer = buffer.new(maxRequiredWriteBufferSize)
	local writeCursor, writeBufferCapacity = writeBuffer:reserve(maxRequiredWriteBufferSize)
	assertTrue(writeBufferCapacity > maxRequiredWriteBufferSize)
	assertTrue(writeBufferCapacity > #options.input)

	local request = ffi.new("iconv_request_t", {
		input = {
			charset = options.from,
			buffer = readCursor,
			length = inputSize,
			remaining = inputSize,
		},
		output = {
			charset = options.to,
			buffer = writeCursor,
			length = writeBufferCapacity,
			remaining = writeBufferCapacity,
		},
		handle = nil,
	})

	local status = iconv.bindings.iconv_convert(request)
	status = tonumber(status)
	assertEquals(status, options.expected.result)
	assertEquals(iconv.strerror(status), iconv.strerror(options.expected.result))

	local numBytesRead = tonumber(request.input.length - request.input.remaining)
	assertEquals(tonumber(request.input.remaining), 0)
	assertEquals(numBytesRead, inputSize)

	local numBytesWritten = tonumber(request.output.length - request.output.remaining)
	assertEquals(numBytesWritten, #options.expected.output)
	assertEquals(tonumber(request.output.length), writeBufferCapacity)
	assertEquals(tonumber(request.output.remaining), writeBufferCapacity - #options.expected.output)

	writeBuffer:commit(numBytesWritten) -- NOOP if zero
	assertEquals(#writeBuffer, #options.expected.output)
	assertEquals(tostring(writeBuffer), options.expected.output)
end

describe("iconv", function()
	describe("bindings", function()
		describe("iconv_convert", function()
			it("should be a NOOP if an empty input buffer was provided", function()
				assertConversionResult({
					input = "",
					from = "CP949",
					to = "UTF-8",
					expected = {
						result = ffi.C.ICONV_RESULT_OK,
						output = "",
					},
				})
			end)

			it("should be able to convert Windows encodings to UTF-8", function()
				assertConversionResult({
					input = "\192\175\192\250\192\206\197\205\198\228\192\204\189\186",
					from = "CP949",
					to = "UTF-8",
					expected = {
						result = ffi.C.ICONV_RESULT_OK,
						output = "유저인터페이스",
					},
				})
			end)
		end)

		describe("iconv_open", function()
			local function resetErrNo()
				ffi.errno(0)
			end
			before(resetErrNo)
			after(resetErrNo)

			it("should indicate an error if the requested conversion isn't supported", function()
				local descriptor = iconv.bindings.iconv_open("Not-a-real-encoding", "UTF-8")
				assertFalse(iconv.bindings.iconv_check_result(descriptor))
				assertFalse(ffi.errno() == 0)
			end)

			it("should return a valid handle if the conversion is supported", function()
				local descriptor = iconv.bindings.iconv_open("CP949", "UTF-8")
				ffi.errno(0)
				assertTrue(iconv.bindings.iconv_check_result(descriptor))
				assertEquals(ffi.errno(), 0)
				iconv.bindings.iconv_close(descriptor)
				assertEquals(ffi.errno(), 0)
			end)
		end)

		describe("iconv", function()
			it("should be able to convert Windows encodings to UTF-8", function()
				local descriptor = iconv.bindings.iconv_open("UTF-8", "CP949")
				assertTrue(iconv.bindings.iconv_check_result(descriptor))

				local input = "\192\175\192\250\192\206\197\205\198\228\192\204\189\186"
				local inputSize = ffi.new("size_t[1]", #input)
				local readBuffer = ffi.new("char[?]", #input, input)
				local inputRef = ffi.new("char*[1]", readBuffer)

				local outputSize = ffi.new("size_t[1]", 256)
				local outputBuffer = ffi.new("char[256]")
				local outputRef = ffi.new("char*[1]", outputBuffer)

				ffi.errno(0)
				iconv.bindings.iconv(descriptor, inputRef, inputSize, outputRef, outputSize)
				assertEquals(ffi.errno(), 0)

				local numBytesWritten = #input - tonumber(inputSize[0])
				assertEquals(tonumber(inputSize[0]), 0)
				assertEquals(numBytesWritten, #input)

				local expectedOutput = "유저인터페이스"
				assertEquals(tonumber(outputSize[0]), 256 - #expectedOutput)
				local converted = ffi.string(outputBuffer)
				assertEquals(converted, expectedOutput)

				local status = iconv.bindings.iconv_close(descriptor)
				assertEquals(status, 0)
			end)
		end)
	end)

	describe("convert", function()
		it("should be able to convert Windows encodings to UTF-8", function()
			local input = "\192\175\192\250\192\206\197\205\198\228\192\204\189\186"
			local output, result = iconv.convert(input, "CP949", "UTF-8")
			assertEquals(output, "유저인터페이스")
			assertEquals(result, iconv.strerror(ffi.C.ICONV_RESULT_OK))
		end)

		it("should be a NOOP if an empty string was passed", function()
			local output, result = iconv.convert("", "CP949", "UTF-8")
			assertEquals(output, "")
			assertEquals(result, iconv.strerror(ffi.C.ICONV_RESULT_OK))
		end)

		it("should fail if the input string isn't given in the input encoding", function()
			local input = "유저인터페이스"
			assertFailure(function()
				return iconv.convert(input, "CP949", "UTF-8")
			end, iconv.strerror(ffi.C.ICONV_CONVERSION_FAILED))
		end)

		it("should fail if the input string was truncated", function()
			local input = "\192\175\192\250\192\206\197\205\198\228\192\204\189" -- Note: Final byte missing
			assertFailure(function()
				return iconv.convert(input, "CP949", "UTF-8")
			end, iconv.strerror(ffi.C.ICONV_INCOMPLETE_INPUT))
		end)

		it("should fail if given an invalid input encoding", function()
			local input = "유저인터페이스"
			assertFailure(function()
				return iconv.convert(input, "INVALID_ENCODING", "UTF-8")
			end, iconv.strerror(ffi.C.ICONV_CONVERSION_FAILED))
		end)

		it("should fail if given an invalid output encoding", function()
			local input = "유저인터페이스"
			assertFailure(function()
				return iconv.convert(input, "UTF-8", "INVALID_ENCODING")
			end, iconv.strerror(ffi.C.ICONV_CONVERSION_FAILED))
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
	end)
end)
