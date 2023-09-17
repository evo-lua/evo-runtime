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
			local rgbaPixelArray, imageWidthInPixels, imageHeightInPixels =
				C_ImageProcessing.DecodeFileContents(EXAMPLE_JPG_BYTES)

			local expectedPixelCount = 4
			local bytesPerPixel = 4 -- RGBA
			assertEquals(#rgbaPixelArray, expectedPixelCount * bytesPerPixel)

			assertEquals(imageWidthInPixels, 2)
			assertEquals(imageHeightInPixels, 2)

			local firstPixel = {
				red = rgbaPixelArray:byte(1),
				green = rgbaPixelArray:byte(2),
				blue = rgbaPixelArray:byte(3),
				alpha = rgbaPixelArray:byte(4),
			}

			local secondPixel = {
				red = rgbaPixelArray:byte(5),
				green = rgbaPixelArray:byte(6),
				blue = rgbaPixelArray:byte(7),
				alpha = rgbaPixelArray:byte(8),
			}

			local thirdPixel = {
				red = rgbaPixelArray:byte(9),
				green = rgbaPixelArray:byte(10),
				blue = rgbaPixelArray:byte(11),
				alpha = rgbaPixelArray:byte(12),
			}

			local fourthPixel = {
				red = rgbaPixelArray:byte(13),
				green = rgbaPixelArray:byte(14),
				blue = rgbaPixelArray:byte(15),
				alpha = rgbaPixelArray:byte(16),
			}

			-- 1 pixel tolerance should hopefully account for JPG compression artifacts
			assertEqualNumbers(firstPixel.red, 255, 1)
			assertEqualNumbers(firstPixel.green, 0, 1)
			assertEqualNumbers(firstPixel.blue, 0, 1)
			assertEqualNumbers(firstPixel.alpha, 255, 1)

			assertEqualNumbers(secondPixel.red, 0, 1)
			assertEqualNumbers(secondPixel.green, 255, 1)
			assertEqualNumbers(secondPixel.blue, 0, 1)
			assertEqualNumbers(secondPixel.alpha, 255, 1)

			assertEqualNumbers(thirdPixel.red, 0, 1)
			assertEqualNumbers(thirdPixel.green, 0, 1)
			assertEqualNumbers(thirdPixel.blue, 255, 1)
			assertEqualNumbers(thirdPixel.alpha, 255, 1)

			assertEqualNumbers(fourthPixel.red, 0, 1)
			assertEqualNumbers(fourthPixel.green, 0, 1)
			assertEqualNumbers(fourthPixel.blue, 0, 1)
			assertEqualNumbers(fourthPixel.alpha, 255, 1)
		end)

		it("should be able to decode JPG file contents from a string buffer", function()
			local rgbaPixelArray, imageWidthInPixels, imageHeightInPixels =
				C_ImageProcessing.DecodeFileContents(EXAMPLE_JPG_BUFFER)

			local expectedPixelCount = 4
			local bytesPerPixel = 4 -- RGBA
			assertEquals(#rgbaPixelArray, expectedPixelCount * bytesPerPixel)

			assertEquals(imageWidthInPixels, 2)
			assertEquals(imageHeightInPixels, 2)

			local firstPixel = {
				red = rgbaPixelArray:byte(1),
				green = rgbaPixelArray:byte(2),
				blue = rgbaPixelArray:byte(3),
				alpha = rgbaPixelArray:byte(4),
			}

			local secondPixel = {
				red = rgbaPixelArray:byte(5),
				green = rgbaPixelArray:byte(6),
				blue = rgbaPixelArray:byte(7),
				alpha = rgbaPixelArray:byte(8),
			}

			local thirdPixel = {
				red = rgbaPixelArray:byte(9),
				green = rgbaPixelArray:byte(10),
				blue = rgbaPixelArray:byte(11),
				alpha = rgbaPixelArray:byte(12),
			}

			local fourthPixel = {
				red = rgbaPixelArray:byte(13),
				green = rgbaPixelArray:byte(14),
				blue = rgbaPixelArray:byte(15),
				alpha = rgbaPixelArray:byte(16),
			}

			-- 1 pixel tolerance should hopefully account for JPG compression artifacts
			assertEqualNumbers(firstPixel.red, 255, 1)
			assertEqualNumbers(firstPixel.green, 0, 1)
			assertEqualNumbers(firstPixel.blue, 0, 1)
			assertEqualNumbers(firstPixel.alpha, 255, 1)

			assertEqualNumbers(secondPixel.red, 0, 1)
			assertEqualNumbers(secondPixel.green, 255, 1)
			assertEqualNumbers(secondPixel.blue, 0, 1)
			assertEqualNumbers(secondPixel.alpha, 255, 1)

			assertEqualNumbers(thirdPixel.red, 0, 1)
			assertEqualNumbers(thirdPixel.green, 0, 1)
			assertEqualNumbers(thirdPixel.blue, 255, 1)
			assertEqualNumbers(thirdPixel.alpha, 255, 1)

			assertEqualNumbers(fourthPixel.red, 0, 1)
			assertEqualNumbers(fourthPixel.green, 0, 1)
			assertEqualNumbers(fourthPixel.blue, 0, 1)
			assertEqualNumbers(fourthPixel.alpha, 255, 1)
		end)

		it("should be able to decode TGA file contents from a string", function()
			local rgbaPixelArray, imageWidthInPixels, imageHeightInPixels =
				C_ImageProcessing.DecodeFileContents(EXAMPLE_TGA_BYTES)
			assertEquals(rgbaPixelArray, EXAMPLE_IMAGE_DATA)
			assertEquals(imageWidthInPixels, 2)
			assertEquals(imageHeightInPixels, 2)
		end)

		it("should be able to decode TGA file contents from a string buffer", function()
			local rgbaPixelArray, imageWidthInPixels, imageHeightInPixels =
				C_ImageProcessing.DecodeFileContents(EXAMPLE_TGA_BUFFER)
			assertEquals(rgbaPixelArray, EXAMPLE_IMAGE_DATA)
			assertEquals(imageWidthInPixels, 2)
			assertEquals(imageHeightInPixels, 2)
		end)

		it("should throw if garbage bytes are passed as the file contents", function()
			local function attemptToDecodeInvalidFile()
				C_ImageProcessing.DecodeFileContents("Not a valid image file")
			end
			local expectedErrorMessage = "Failed to decode image data (stbi_load_rgba returned NULL)"
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
