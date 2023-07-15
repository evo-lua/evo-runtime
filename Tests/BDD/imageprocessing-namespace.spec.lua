local EXAMPLE_IMAGE_DATA = "\255\0\0\0\0\255\0\0\0\0\255\0\0\0\0\255"
local EXAMPLE_IMAGE_BUFFER = buffer.new():put(EXAMPLE_IMAGE_DATA)
local EXAMPLE_BMP_BYTES = C_FileSystem.ReadFile(path.join("Tests", "Fixtures", "rgba-pixels.bmp"))
local EXAMPLE_PNG_BYTES = C_FileSystem.ReadFile(path.join("Tests", "Fixtures", "rgba-pixels.png"))
local EXAMPLE_JPG_BYTES = C_FileSystem.ReadFile(path.join("Tests", "Fixtures", "rgba-pixels.jpg"))
local EXAMPLE_TGA_BYTES = C_FileSystem.ReadFile(path.join("Tests", "Fixtures", "rgba-pixels.tga"))
local EXAMPLE_BMP_BUFFER = buffer.new():put(EXAMPLE_BMP_BYTES)
local EXAMPLE_PNG_BUFFER = buffer.new():put(EXAMPLE_PNG_BYTES)
local EXAMPLE_JPG_BUFFER = buffer.new():put(EXAMPLE_JPG_BYTES)
local EXAMPLE_TGA_BUFFER = buffer.new():put(EXAMPLE_TGA_BYTES)

describe("C_ImageProcessing", function()
	describe("DecodeFileContents", function()
		it("should be able to decode BMP file contents from a string", function()
			local rgbaPixelArray, imageWidthInPixels, imageHeightInPixels =
				C_ImageProcessing.DecodeFileContents(EXAMPLE_BMP_BYTES)
			assertEquals(rgbaPixelArray, EXAMPLE_IMAGE_DATA)
			assertEquals(imageWidthInPixels, 2)
			assertEquals(imageHeightInPixels, 2)
		end)

		it("should be able to decode BMP file contents from a string buffer", function()
			local rgbaPixelArray, imageWidthInPixels, imageHeightInPixels =
				C_ImageProcessing.DecodeFileContents(EXAMPLE_BMP_BUFFER)
			assertEquals(rgbaPixelArray, EXAMPLE_IMAGE_DATA)
			assertEquals(imageWidthInPixels, 2)
			assertEquals(imageHeightInPixels, 2)
		end)

		it("should be able to decode PNG file contents from a string", function()
			local rgbaPixelArray, imageWidthInPixels, imageHeightInPixels =
				C_ImageProcessing.DecodeFileContents(EXAMPLE_PNG_BYTES)
			assertEquals(rgbaPixelArray, EXAMPLE_IMAGE_DATA)
			assertEquals(imageWidthInPixels, 2)
			assertEquals(imageHeightInPixels, 2)
		end)

		it("should be able to decode PNG file contents from a string buffer", function()
			local rgbaPixelArray, imageWidthInPixels, imageHeightInPixels =
				C_ImageProcessing.DecodeFileContents(EXAMPLE_PNG_BUFFER)
			assertEquals(rgbaPixelArray, EXAMPLE_IMAGE_DATA)
			assertEquals(imageWidthInPixels, 2)
			assertEquals(imageHeightInPixels, 2)
		end)

		it("should be able to decode JPG file contents from a string", function()
			local rgbPixelArray, imageWidthInPixels, imageHeightInPixels =
				C_ImageProcessing.DecodeFileContents(EXAMPLE_JPG_BYTES)
			-- JPG compression and lack of alpha channel makes a direct comparison impossible
			local isFirstColorApproximatelyRed = (
				rgbPixelArray:byte(1) > 250
				and rgbPixelArray:byte(2) < 5
				and rgbPixelArray:byte(3) < 5
			)
			local isSecondColorApproximatelyGreen = (
				rgbPixelArray:byte(5) > 250
				and rgbPixelArray:byte(6) < 5
				and rgbPixelArray:byte(7) < 5
			)
			local isThirdColorApproximatelyBlue = (
				rgbPixelArray:byte(9) > 250
				and rgbPixelArray:byte(10) < 5
				and rgbPixelArray:byte(11) < 5
			)
			assertTrue(isFirstColorApproximatelyRed)
			assertTrue(isSecondColorApproximatelyGreen)
			assertTrue(isThirdColorApproximatelyBlue)
			assertEquals(imageWidthInPixels, 2)
			assertEquals(imageHeightInPixels, 2)
		end)

		it("should be able to decode JPG file contents from a string buffer", function()
			local rgbaPixelArray, imageWidthInPixels, imageHeightInPixels =
				C_ImageProcessing.DecodeFileContents(EXAMPLE_JPG_BUFFER)
			-- JPG compression and lack of alpha channel makes a direct comparison impossible
			local isFirstColorApproximatelyRed = (
				rgbaPixelArray:byte(1) > 250
				and rgbaPixelArray:byte(2) < 5
				and rgbaPixelArray:byte(3) < 5
			)
			local isSecondColorApproximatelyGreen = (
				rgbaPixelArray:byte(5) > 250
				and rgbaPixelArray:byte(6) < 5
				and rgbaPixelArray:byte(7) < 5
			)
			local isThirdColorApproximatelyBlue = (
				rgbaPixelArray:byte(9) > 250
				and rgbaPixelArray:byte(10) < 5
				and rgbaPixelArray:byte(11) < 5
			)
			assertTrue(isFirstColorApproximatelyRed)
			assertTrue(isSecondColorApproximatelyGreen)
			assertTrue(isThirdColorApproximatelyBlue)
			assertEquals(imageWidthInPixels, 2)
			assertEquals(imageHeightInPixels, 2)
		end)

		it("should throw if garbage bytes are passed as the file contents", function()
			local function attemptToDecodeInvalidFile()
				C_ImageProcessing.DecodeFileContents("Not a valid image file")
			end
			local expectedErrorMessage = "Failed to decode image data (stbi_load_image returned NULL)"
			assertThrows(attemptToDecodeInvalidFile, expectedErrorMessage)
		end)

		it("should throw if a non-string type was passed", function()
			local function attemptToDecodeInvalidFile()
				C_ImageProcessing.DecodeFileContents(123)
			end
			local expectedErrorMessage =
				"Expected argument imageFileContents to be a string value, but received a number value instead"
			assertThrows(attemptToDecodeInvalidFile, expectedErrorMessage)
		end)
	end)

	describe("EncodeBMP", function()
		it("should be able to encode pixel data given as a string", function()
			local bmpFileContents = C_ImageProcessing.EncodeBMP(EXAMPLE_IMAGE_DATA, 2, 2)
			assertEquals(bmpFileContents, EXAMPLE_BMP_BYTES)
		end)

		it("should be able to encode pixel data given as a string buffer", function()
			local bmpFileContents = C_ImageProcessing.EncodeBMP(EXAMPLE_IMAGE_BUFFER, 2, 2)
			assertEquals(bmpFileContents, EXAMPLE_BMP_BYTES)
		end)

		it("should throw if a non-string type was passed as the pixel buffer", function()
			local function attemptToEncodeInvalidFile()
				C_ImageProcessing.EncodeBMP(123, 2, 2)
			end
			local expectedErrorMessage =
				"Expected argument rgbaPixelArray to be a string value, but received a number value instead"
			assertThrows(attemptToEncodeInvalidFile, expectedErrorMessage)
		end)

		it("should throw if a non-number type was passed as the image width", function()
			local function attemptToEncodeInvalidFile()
				C_ImageProcessing.EncodeBMP(EXAMPLE_IMAGE_DATA, "2", 2)
			end
			local expectedErrorMessage =
				"Expected argument imageWidthInPixels to be a number value, but received a string value instead"
			assertThrows(attemptToEncodeInvalidFile, expectedErrorMessage)
		end)

		it("should throw if a non-number type was passed as the image height", function()
			local function attemptToEncodeInvalidFile()
				C_ImageProcessing.EncodeBMP(EXAMPLE_IMAGE_DATA, 2, "2")
			end
			local expectedErrorMessage =
				"Expected argument imageHeightInPixels to be a number value, but received a string value instead"
			assertThrows(attemptToEncodeInvalidFile, expectedErrorMessage)
		end)
	end)

	describe("EncodePNG", function()
		it("should be able to encode pixel data given as a string", function()
			local pngFileContents = C_ImageProcessing.EncodePNG(EXAMPLE_IMAGE_DATA, 2, 2)
			assertEquals(pngFileContents, EXAMPLE_PNG_BYTES)
		end)

		it("should be able to encode pixel data given as a string buffer", function()
			local pngFileContents = C_ImageProcessing.EncodePNG(EXAMPLE_IMAGE_BUFFER, 2, 2)
			assertEquals(pngFileContents, EXAMPLE_PNG_BYTES)
		end)

		it("should throw if a non-string type was passed as the pixel buffer", function()
			local function attemptToEncodeInvalidFile()
				C_ImageProcessing.EncodePNG(123, 2, 2)
			end
			local expectedErrorMessage =
				"Expected argument rgbaPixelArray to be a string value, but received a number value instead"
			assertThrows(attemptToEncodeInvalidFile, expectedErrorMessage)
		end)

		it("should throw if a non-number type was passed as the image width", function()
			local function attemptToEncodeInvalidFile()
				C_ImageProcessing.EncodePNG(EXAMPLE_IMAGE_DATA, "2", 2)
			end
			local expectedErrorMessage =
				"Expected argument imageWidthInPixels to be a number value, but received a string value instead"
			assertThrows(attemptToEncodeInvalidFile, expectedErrorMessage)
		end)

		it("should throw if a non-number type was passed as the image height", function()
			local function attemptToEncodeInvalidFile()
				C_ImageProcessing.EncodePNG(EXAMPLE_IMAGE_DATA, 2, "2")
			end
			local expectedErrorMessage =
				"Expected argument imageHeightInPixels to be a number value, but received a string value instead"
			assertThrows(attemptToEncodeInvalidFile, expectedErrorMessage)
		end)
	end)

	describe("EncodeJPG", function()
		it("should be able to encode pixel data given as a string", function()
			local jpgFileContents = C_ImageProcessing.EncodeJPG(EXAMPLE_IMAGE_DATA, 2, 2)
			assertEquals(jpgFileContents, EXAMPLE_JPG_BYTES)
		end)

		it("should be able to encode pixel data given as a string buffer", function()
			local jpgFileContents = C_ImageProcessing.EncodeJPG(EXAMPLE_IMAGE_BUFFER, 2, 2)
			assertEquals(jpgFileContents, EXAMPLE_JPG_BYTES)
		end)

		it("should throw if a non-string type was passed as the pixel buffer", function()
			local function attemptToEncodeInvalidFile()
				C_ImageProcessing.EncodeJPG(123, 2, 2)
			end
			local expectedErrorMessage =
				"Expected argument rgbaPixelArray to be a string value, but received a number value instead"
			assertThrows(attemptToEncodeInvalidFile, expectedErrorMessage)
		end)

		it("should throw if a non-number type was passed as the image width", function()
			local function attemptToEncodeInvalidFile()
				C_ImageProcessing.EncodeJPG(EXAMPLE_IMAGE_DATA, "2", 2)
			end
			local expectedErrorMessage =
				"Expected argument imageWidthInPixels to be a number value, but received a string value instead"
			assertThrows(attemptToEncodeInvalidFile, expectedErrorMessage)
		end)

		it("should throw if a non-number type was passed as the image height", function()
			local function attemptToEncodeInvalidFile()
				C_ImageProcessing.EncodeJPG(EXAMPLE_IMAGE_DATA, 2, "2")
			end
			local expectedErrorMessage =
				"Expected argument imageHeightInPixels to be a number value, but received a string value instead"
			assertThrows(attemptToEncodeInvalidFile, expectedErrorMessage)
		end)
	end)

	describe("EncodeTGA", function()
		it("should be able to encode pixel data given as a string", function()
			local bmpFileContents = C_ImageProcessing.EncodeTGA(EXAMPLE_IMAGE_DATA, 2, 2)
			assertEquals(bmpFileContents, EXAMPLE_TGA_BYTES)
		end)

		it("should be able to encode pixel data given as a string buffer", function()
			local bmpFileContents = C_ImageProcessing.EncodeTGA(EXAMPLE_IMAGE_BUFFER, 2, 2)
			assertEquals(bmpFileContents, EXAMPLE_TGA_BYTES)
		end)

		it("should throw if a non-string type was passed as the pixel buffer", function()
			local function attemptToEncodeInvalidFile()
				C_ImageProcessing.EncodeTGA(123, 2, 2)
			end
			local expectedErrorMessage =
				"Expected argument rgbaPixelArray to be a string value, but received a number value instead"
			assertThrows(attemptToEncodeInvalidFile, expectedErrorMessage)
		end)

		it("should throw if a non-number type was passed as the image width", function()
			local function attemptToEncodeInvalidFile()
				C_ImageProcessing.EncodeTGA(EXAMPLE_IMAGE_DATA, "2", 2)
			end
			local expectedErrorMessage =
				"Expected argument imageWidthInPixels to be a number value, but received a string value instead"
			assertThrows(attemptToEncodeInvalidFile, expectedErrorMessage)
		end)

		it("should throw if a non-number type was passed as the image height", function()
			local function attemptToEncodeInvalidFile()
				C_ImageProcessing.EncodeTGA(EXAMPLE_IMAGE_DATA, 2, "2")
			end
			local expectedErrorMessage =
				"Expected argument imageHeightInPixels to be a number value, but received a string value instead"
			assertThrows(attemptToEncodeInvalidFile, expectedErrorMessage)
		end)
	end)
end)
