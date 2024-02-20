local ffi = require("ffi")
local stbi = require("stbi")

local FIXTURES_DIR = path.join("Tests", "Fixtures")

local EXAMPLE_FILE_CONTENTS = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
local EXAMPLE_IMAGE_BUFFER = buffer.new(#EXAMPLE_FILE_CONTENTS):put(EXAMPLE_FILE_CONTENTS)
local EXAMPLE_IMAGE = ffi.new("stbi_image_t")
EXAMPLE_IMAGE.width = 2
EXAMPLE_IMAGE.height = 3
EXAMPLE_IMAGE.data = EXAMPLE_IMAGE_BUFFER
EXAMPLE_IMAGE.channels = 4

describe("stbi", function()
	describe("bindings", function()
		it("should export the entirety of the stbi API", function()
			local exportedApiSurface = {
				"stbi_version",
				"stbi_image_info",
				"stbi_load_image",
				"stbi_image_free",
				"stbi_load_rgb",
				"stbi_load_rgba",
				"stbi_load_monochrome",
				"stbi_load_monochrome_with_alpha",
				"stbi_encode_bmp",
				"stbi_encode_png",
				"stbi_encode_jpg",
				"stbi_encode_tga",
				"stbi_flip_vertically_on_write",
				"stbi_get_required_bmp_size",
				"stbi_get_required_png_size",
				"stbi_get_required_jpg_size",
				"stbi_get_required_tga_size",
			}

			for _, functionName in ipairs(exportedApiSurface) do
				assertEquals(type(stbi.bindings[functionName]), "cdata")
			end
		end)

		describe("stbi_image_info", function()
			local fileContents = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
			it("should return metadata about the image if the buffer contains a supported image format", function()
				local imageInfo = ffi.new("stbi_image_t")
				local result = stbi.bindings.stbi_image_info(fileContents, #fileContents, imageInfo)

				assertTrue(result)
				assertEquals(imageInfo.width, 2)
				assertEquals(imageInfo.height, 3)
				assertEquals(imageInfo.channels, 3)
			end)

			it("should return false if a null pointer was passed as the result", function()
				local result = stbi.bindings.stbi_image_info(fileContents, #fileContents, nil)
				assertFalse(result)
			end)

			it("should return false if no image data was found in the buffer", function()
				local result = stbi.bindings.stbi_image_info("not an image", 11, nil)
				assertFalse(result)
			end)

			it("should return false if the buffer size given was zero", function()
				local result = stbi.bindings.stbi_image_info(fileContents, 0, nil)
				assertFalse(result)
			end)

			it("should return false if the buffer size given was negative", function()
				local result = stbi.bindings.stbi_image_info(fileContents, -1, nil)
				assertFalse(result)
			end)
		end)

		describe("stbi_load_image", function()
			local fileContents = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
			it("should return the decoded image data if the buffer contains a supported image format", function()
				local imageInfo = ffi.new("stbi_image_t")
				local result = stbi.bindings.stbi_load_image(fileContents, #fileContents, imageInfo)

				assertTrue(result)
				assertEquals(imageInfo.width, 2)
				assertEquals(imageInfo.height, 3)
				assertEquals(imageInfo.channels, 3)

				local expectedPixels = {
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
				}

				for i = 0, imageInfo.width * imageInfo.height * imageInfo.channels - 1 do
					assertEquals(imageInfo.data[i], expectedPixels[i + 1])
				end

				stbi.bindings.stbi_image_free(imageInfo)
			end)

			it("should return false if a null pointer was passed as the result", function()
				local result = stbi.bindings.stbi_load_image(fileContents, #fileContents, nil)
				assertFalse(result)
			end)

			it("should return false if no image data was found in the buffer", function()
				local result = stbi.bindings.stbi_load_image("not an image", 11, nil)
				assertFalse(result)
			end)

			it("should return false if the buffer size given was zero", function()
				local result = stbi.bindings.stbi_load_image(fileContents, 0, nil)
				assertFalse(result)
			end)

			it("should return false if the buffer size given was negative", function()
				local result = stbi.bindings.stbi_load_image(fileContents, -1, nil)
				assertFalse(result)
			end)
		end)

		describe("stbi_flip_vertically_on_write", function()
			it("should flip images on the Y axis when encoding them", function()
				local fileContents = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
				local image = ffi.new("stbi_image_t")
				local result = buffer.new()
				stbi.bindings.stbi_load_image(fileContents, #fileContents, image)

				stbi.bindings.stbi_flip_vertically_on_write(true)

				local maxFileSize = tonumber(stbi.bindings.stbi_get_required_bmp_size(image))
				local startPointer, length = result:reserve(maxFileSize)
				local numBytesWritten = stbi.bindings.stbi_encode_bmp(image, startPointer, length)
				result:commit(numBytesWritten)

				stbi.bindings.stbi_flip_vertically_on_write(false)

				-- It should just have set the verticalDirection to -1 inside the BMP header
				-- Since that's a bit difficult to test here, just make sure that the image can still be decoded properly
				local encodedFileContents = tostring(result)
				stbi.bindings.stbi_load_image(encodedFileContents, #encodedFileContents, image)

				local expectedPixels = {
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
				}

				for i = 0, image.width * image.height * image.channels - 1 do
					assertEquals(image.data[i], expectedPixels[i + 1])
				end

				stbi.bindings.stbi_image_free(image)
			end)
		end)

		describe("stbi_encode_bmp", function()
			local fileContents = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
			local image = ffi.new("stbi_image_t")
			local result = buffer.new()
			it("should return the encoded file length after storing the pixel data", function()
				stbi.bindings.stbi_load_image(fileContents, #fileContents, image)

				local decodedPixelData = ffi.string(image.data, image.width * image.height * image.channels)

				local maxFileSize = tonumber(stbi.bindings.stbi_get_required_bmp_size(image))
				local startPointer, length = result:reserve(maxFileSize)
				local numBytesWritten = stbi.bindings.stbi_encode_bmp(image, startPointer, length)

				assertTrue(tonumber(numBytesWritten) > 0)
				assertTrue(tonumber(numBytesWritten) <= maxFileSize)

				result:commit(numBytesWritten)

				local encodedFileContents = tostring(result)
				stbi.bindings.stbi_load_image(encodedFileContents, #encodedFileContents, image)

				local encodedPixelData = ffi.string(image.data, image.width * image.height * image.channels)
				assertEquals(encodedPixelData, decodedPixelData)
				assertEquals(image.width, 2)
				assertEquals(image.height, 3)
				assertEquals(image.channels, 3)

				local expectedPixels = {
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
				}

				for i = 0, image.width * image.height * image.channels - 1 do
					assertEquals(image.data[i], expectedPixels[i + 1])
				end

				stbi.bindings.stbi_image_free(image)
			end)

			it("should return zero if a null pointer was passed as the result", function()
				local numBytesWritten = stbi.bindings.stbi_encode_bmp(image, nil, 0)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if no image was given", function()
				local empyBuffer = buffer.new(42)
				local ptr, len = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_bmp(nil, ptr, len)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if no pixel data was given", function()
				image.data = nil
				local empyBuffer = buffer.new(42)
				local ptr, len = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_bmp(image, ptr, len)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if the buffer size given was zero", function()
				local empyBuffer = buffer.new(42)
				local ptr, _ = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_bmp(image, ptr, 0)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if the buffer size given was negative", function()
				local empyBuffer = buffer.new(42)
				local ptr, _ = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_bmp(image, ptr, -1)
				assertEquals(tonumber(numBytesWritten), 0)
			end)
		end)

		describe("stbi_encode_tga", function()
			local fileContents = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
			local image = ffi.new("stbi_image_t")
			local result = buffer.new()
			it("should return the encoded file length after storing the pixel data", function()
				stbi.bindings.stbi_load_image(fileContents, #fileContents, image)

				local decodedPixelData = ffi.string(image.data, image.width * image.height * image.channels)

				local maxFileSize = tonumber(stbi.bindings.stbi_get_required_tga_size(image))
				local startPointer, length = result:reserve(maxFileSize)
				local numBytesWritten = stbi.bindings.stbi_encode_tga(image, startPointer, length)

				assertTrue(tonumber(numBytesWritten) > 0)
				assertTrue(tonumber(numBytesWritten) <= maxFileSize)

				result:commit(numBytesWritten)

				local encodedFileContents = tostring(result)
				stbi.bindings.stbi_load_image(encodedFileContents, #encodedFileContents, image)

				local encodedPixelData = ffi.string(image.data, image.width * image.height * image.channels)
				assertEquals(encodedPixelData, decodedPixelData)
				assertEquals(image.width, 2)
				assertEquals(image.height, 3)
				assertEquals(image.channels, 3)

				local expectedPixels = {
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
				}

				for i = 0, image.width * image.height * image.channels - 1 do
					assertEquals(image.data[i], expectedPixels[i + 1])
				end

				stbi.bindings.stbi_image_free(image)
			end)

			it("should return zero if a null pointer was passed as the result", function()
				local numBytesWritten = stbi.bindings.stbi_encode_tga(image, nil, 0)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if no image was given", function()
				local empyBuffer = buffer.new(42)
				local ptr, len = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_tga(nil, ptr, len)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if no pixel data was given", function()
				image.data = nil
				local empyBuffer = buffer.new(42)
				local ptr, len = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_tga(image, ptr, len)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if the buffer size given was zero", function()
				local empyBuffer = buffer.new(42)
				local ptr, _ = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_tga(image, ptr, 0)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if the buffer size given was negative", function()
				local empyBuffer = buffer.new(42)
				local ptr, _ = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_tga(image, ptr, -1)
				assertEquals(tonumber(numBytesWritten), 0)
			end)
		end)

		describe("stbi_encode_jpg", function()
			local fileContents = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
			local image = ffi.new("stbi_image_t")
			local result = buffer.new()
			it("should return the encoded file length after storing the pixel data", function()
				stbi.bindings.stbi_load_image(fileContents, #fileContents, image)

				local decodedPixelData = ffi.string(image.data, image.width * image.height * image.channels)

				local maxFileSize = tonumber(stbi.bindings.stbi_get_required_jpg_size(image, 100))

				local startPointer, length = result:reserve(maxFileSize)
				local numBytesWritten = stbi.bindings.stbi_encode_jpg(image, startPointer, length, 100)

				assertTrue(tonumber(numBytesWritten) > 0)
				assertTrue(tonumber(numBytesWritten) <= maxFileSize)

				result:commit(numBytesWritten)

				local encodedFileContents = tostring(result)
				stbi.bindings.stbi_load_image(encodedFileContents, #encodedFileContents, image)

				local encodedPixelData = ffi.string(image.data, image.width * image.height * image.channels)

				-- With JPEG compression there may be slight artifacts, so the pixel data won't match exactly
				assertEquals(#encodedPixelData, #decodedPixelData)
				assertEquals(image.width, 2)
				assertEquals(image.height, 3)
				assertEquals(image.channels, 3)

				local expectedPixels = {
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
				}

				for i = 0, image.width * image.height * image.channels - 1 do
					-- Close enough, will have to do here since JPEG blurs the output slightly
					local allowedDelta = 5
					assertTrue(math.abs(image.data[i] - expectedPixels[i + 1]) < allowedDelta)
				end

				stbi.bindings.stbi_image_free(image)
			end)

			it("should return zero if a null pointer was passed as the result", function()
				local numBytesWritten = stbi.bindings.stbi_encode_jpg(image, nil, 0, 100)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if no image was given", function()
				local empyBuffer = buffer.new(42)
				local ptr, len = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_jpg(nil, ptr, len, 100)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if no pixel data was given", function()
				image.data = nil
				local empyBuffer = buffer.new(42)
				local ptr, len = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_jpg(image, ptr, len, 100)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if the buffer size given was zero", function()
				local empyBuffer = buffer.new(42)
				local ptr, _ = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_jpg(image, ptr, 0, 100)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if the buffer size given was negative", function()
				local empyBuffer = buffer.new(42)
				local ptr, _ = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_jpg(image, ptr, -1, 100)
				assertEquals(tonumber(numBytesWritten), 0)
			end)
		end)

		describe("stbi_encode_png", function()
			local fileContents = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
			local image = ffi.new("stbi_image_t")
			local result = buffer.new()
			it("should return the encoded file length after storing the pixel data", function()
				stbi.bindings.stbi_load_image(fileContents, #fileContents, image)

				local decodedPixelData = ffi.string(image.data, image.width * image.height * image.channels)

				local maxFileSize = tonumber(stbi.bindings.stbi_get_required_bmp_size(image))
				local startPointer, length = result:reserve(maxFileSize)
				local numBytesWritten = stbi.bindings.stbi_encode_png(image, startPointer, length, 0)

				assertTrue(tonumber(numBytesWritten) > 0)
				assertTrue(tonumber(numBytesWritten) <= maxFileSize)

				result:commit(numBytesWritten)

				local encodedFileContents = tostring(result)
				stbi.bindings.stbi_load_image(encodedFileContents, #encodedFileContents, image)

				local encodedPixelData = ffi.string(image.data, image.width * image.height * image.channels)
				assertEquals(encodedPixelData, decodedPixelData)
				assertEquals(image.width, 2)
				assertEquals(image.height, 3)
				assertEquals(image.channels, 3)

				local expectedPixels = {
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
				}

				for i = 0, image.width * image.height * image.channels - 1 do
					assertEquals(image.data[i], expectedPixels[i + 1])
				end

				stbi.bindings.stbi_image_free(image)
			end)

			it("should return zero if a null pointer was passed as the result", function()
				local numBytesWritten = stbi.bindings.stbi_encode_png(image, nil, 0, 0)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if no image was given", function()
				local empyBuffer = buffer.new(42)
				local ptr, len = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_png(nil, ptr, len, 0)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if no pixel data was given", function()
				image.data = nil
				local empyBuffer = buffer.new(42)
				local ptr, len = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_png(image, ptr, len, 0)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if the buffer size given was zero", function()
				local empyBuffer = buffer.new(42)
				local ptr, _ = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_png(image, ptr, 0, 0)
				assertEquals(tonumber(numBytesWritten), 0)
			end)

			it("should return zero if the buffer size given was negative", function()
				local empyBuffer = buffer.new(42)
				local ptr, _ = empyBuffer:ref()
				local numBytesWritten = stbi.bindings.stbi_encode_png(image, ptr, -1, 0)
				assertEquals(tonumber(numBytesWritten), 0)
			end)
		end)

		describe("stbi_load_rgb", function()
			local fileContents = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
			it("should return the decoded image data if the buffer contains a supported image format", function()
				local imageInfo = ffi.new("stbi_image_t")
				local result = stbi.bindings.stbi_load_rgb(fileContents, #fileContents, imageInfo)

				assertTrue(result)
				assertEquals(imageInfo.width, 2)
				assertEquals(imageInfo.height, 3)
				assertEquals(imageInfo.channels, 3)

				local expectedPixels = {
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
					0,
					0,
					255,
				}

				for i = 0, imageInfo.width * imageInfo.height * imageInfo.channels - 1 do
					assertEquals(imageInfo.data[i], expectedPixels[i + 1])
				end

				stbi.bindings.stbi_image_free(imageInfo)
			end)

			it("should return false if a null pointer was passed as the result", function()
				local result = stbi.bindings.stbi_load_rgb(fileContents, #fileContents, nil)
				assertFalse(result)
			end)

			it("should return false if no image data was found in the buffer", function()
				local result = stbi.bindings.stbi_load_rgb("not an image", 11, nil)
				assertFalse(result)
			end)

			it("should return false if the buffer size given was zero", function()
				local result = stbi.bindings.stbi_load_rgb(fileContents, 0, nil)
				assertFalse(result)
			end)

			it("should return false if the buffer size given was negative", function()
				local result = stbi.bindings.stbi_load_rgb(fileContents, -1, nil)
				assertFalse(result)
			end)
		end)

		describe("stbi_load_rgba", function()
			local fileContents = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
			it("should return the decoded image data if the buffer contains a supported image format", function()
				local imageInfo = ffi.new("stbi_image_t")
				local result = stbi.bindings.stbi_load_rgba(fileContents, #fileContents, imageInfo)

				assertTrue(result)
				assertEquals(imageInfo.width, 2)
				assertEquals(imageInfo.height, 3)
				assertEquals(imageInfo.channels, 3)

				local expectedPixels = {
					0,
					0,
					255,
					255,
					0,
					0,
					255,
					255,
					0,
					0,
					255,
					255,
					0,
					0,
					255,
					255,
					0,
					0,
					255,
					255,
					0,
					0,
					255,
					255,
				}

				for i = 0, imageInfo.width * imageInfo.height * imageInfo.channels - 1 do
					assertEquals(imageInfo.data[i], expectedPixels[i + 1])
				end

				stbi.bindings.stbi_image_free(imageInfo)
			end)

			it("should return false if a null pointer was passed as the result", function()
				local result = stbi.bindings.stbi_load_rgba(fileContents, #fileContents, nil)
				assertFalse(result)
			end)

			it("should return false if no image data was found in the buffer", function()
				local result = stbi.bindings.stbi_load_rgba("not an image", 11, nil)
				assertFalse(result)
			end)

			it("should return false if the buffer size given was zero", function()
				local result = stbi.bindings.stbi_load_rgba(fileContents, 0, nil)
				assertFalse(result)
			end)

			it("should return false if the buffer size given was negative", function()
				local result = stbi.bindings.stbi_load_rgba(fileContents, -1, nil)
				assertFalse(result)
			end)
		end)

		describe("stbi_load_monochrome", function()
			local fileContents = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
			it("should return the decoded image data if the buffer contains a supported image format", function()
				local imageInfo = ffi.new("stbi_image_t")
				local result = stbi.bindings.stbi_load_monochrome(fileContents, #fileContents, imageInfo)

				assertTrue(result)
				assertEquals(imageInfo.width, 2)
				assertEquals(imageInfo.height, 3)
				assertEquals(imageInfo.channels, 3)

				local expectedPixels = {
					-- Not sure if this is what I'd consider 'monochrome', but it's what stbi does so let's leave it for now
					28,
					28,
					28,
					28,
					28,
					28,
				}

				-- stbi doesn't set the channels to the actual result here, but rather what it "would have been" originally...
				local MONOCHROME_COLOR_DEPTH = 1
				for i = 0, imageInfo.width * imageInfo.height * MONOCHROME_COLOR_DEPTH - 1 do
					assertEquals(imageInfo.data[i], expectedPixels[i + 1])
				end

				stbi.bindings.stbi_image_free(imageInfo)
			end)

			it("should return false if a null pointer was passed as the result", function()
				local result = stbi.bindings.stbi_load_monochrome(fileContents, #fileContents, nil)
				assertFalse(result)
			end)

			it("should return false if no image data was found in the buffer", function()
				local result = stbi.bindings.stbi_load_monochrome("not an image", 11, nil)
				assertFalse(result)
			end)

			it("should return false if the buffer size given was zero", function()
				local result = stbi.bindings.stbi_load_monochrome(fileContents, 0, nil)
				assertFalse(result)
			end)

			it("should return false if the buffer size given was negative", function()
				local result = stbi.bindings.stbi_load_monochrome(fileContents, -1, nil)
				assertFalse(result)
			end)
		end)

		describe("stbi_load_monochrome_with_alpha", function()
			local fileContents = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
			it("should return the decoded image data if the buffer contains a supported image format", function()
				local imageInfo = ffi.new("stbi_image_t")
				local result = stbi.bindings.stbi_load_monochrome_with_alpha(fileContents, #fileContents, imageInfo)

				assertTrue(result)
				assertEquals(imageInfo.width, 2)
				assertEquals(imageInfo.height, 3)
				assertEquals(imageInfo.channels, 3)

				local expectedPixels = {
					-- Not sure if this is what I'd consider 'monochrome', but it's what stbi does so let's leave it for now
					28,
					255,
					28,
					255,
					28,
					255,
					28,
					255,
					28,
					255,
					28,
					255,
				}

				-- stbi doesn't set the channels to the actual result here, but rather what it "would have been" originally...
				local MONOCHROME_ALPHA_COLOR_DEPTH = 2
				for i = 0, imageInfo.width * imageInfo.height * MONOCHROME_ALPHA_COLOR_DEPTH - 1 do
					assertEquals(imageInfo.data[i], expectedPixels[i + 1])
				end
				stbi.bindings.stbi_image_free(imageInfo)
			end)

			it("should return false if a null pointer was passed as the result", function()
				local result = stbi.bindings.stbi_load_monochrome_with_alpha(fileContents, #fileContents, nil)
				assertFalse(result)
			end)

			it("should return false if no image data was found in the buffer", function()
				local result = stbi.bindings.stbi_load_monochrome_with_alpha("not an image", 11, nil)
				assertFalse(result)
			end)

			it("should return false if the buffer size given was zero", function()
				local result = stbi.bindings.stbi_load_monochrome_with_alpha(fileContents, 0, nil)
				assertFalse(result)
			end)

			it("should return false if the buffer size given was negative", function()
				local result = stbi.bindings.stbi_load_monochrome_with_alpha(fileContents, -1, nil)
				assertFalse(result)
			end)
		end)

		describe("stbi_get_required_bmp_size", function()
			it("should return the required BMP size for the given image", function()
				local requiredBufferSize = tonumber(stbi.bindings.stbi_get_required_bmp_size(EXAMPLE_IMAGE))

				local outputBuffer = buffer.new()
				local ptr, len = outputBuffer:reserve(requiredBufferSize)
				local numBytesWritten = stbi.bindings.stbi_encode_bmp(EXAMPLE_IMAGE, ptr, len)
				outputBuffer:commit(numBytesWritten)

				assertEquals(tonumber(requiredBufferSize), #outputBuffer)
			end)
		end)

		describe("stbi_get_required_png_size", function()
			it("should return the required PNG size for the given image", function()
				local requiredBufferSize = stbi.bindings.stbi_get_required_png_size(EXAMPLE_IMAGE, 0)

				local outputBuffer = buffer.new()
				local ptr, len = outputBuffer:reserve(requiredBufferSize)
				local numBytesWritten = stbi.bindings.stbi_encode_png(EXAMPLE_IMAGE, ptr, len, 0)
				outputBuffer:commit(numBytesWritten)

				assertEquals(tonumber(requiredBufferSize), #outputBuffer)
			end)
		end)

		describe("stbi_get_required_jpg_size", function()
			it("should return the required JPG size for the given image", function()
				local requiredBufferSize = stbi.bindings.stbi_get_required_jpg_size(EXAMPLE_IMAGE, 100)

				local outputBuffer = buffer.new()
				local ptr, len = outputBuffer:reserve(requiredBufferSize)
				local numBytesWritten = stbi.bindings.stbi_encode_jpg(EXAMPLE_IMAGE, ptr, len, 100)
				outputBuffer:commit(numBytesWritten)

				assertEquals(tonumber(requiredBufferSize), #outputBuffer)
			end)
		end)

		describe("stbi_get_required_tga_size", function()
			it("should return the required TGA size for the given image", function()
				local requiredBufferSize = stbi.bindings.stbi_get_required_tga_size(EXAMPLE_IMAGE)

				local outputBuffer = buffer.new()
				local ptr, len = outputBuffer:reserve(requiredBufferSize)
				local numBytesWritten = stbi.bindings.stbi_encode_tga(EXAMPLE_IMAGE, ptr, len)
				outputBuffer:commit(numBytesWritten)

				assertEquals(tonumber(requiredBufferSize), #outputBuffer)
			end)
		end)

		describe("stbi_abgr_to_rgba", function()
			it("should swap the pixel format of a given image from ABGR to RGBA", function()
				local imageBytes = "\1\2\3\4\5\6\7\8"
				local image = ffi.new("stbi_image_t")
				image.width = 2
				image.height = 1
				image.data = buffer.new(#imageBytes):put(imageBytes)
				image.channels = 4

				stbi.bindings.stbi_abgr_to_rgba(image)

				assertEquals(image.data[0], 4)
				assertEquals(image.data[1], 3)
				assertEquals(image.data[2], 2)
				assertEquals(image.data[3], 1)
				assertEquals(image.data[4], 8)
				assertEquals(image.data[5], 7)
				assertEquals(image.data[6], 6)
				assertEquals(image.data[7], 5)

				stbi.bindings.stbi_abgr_to_rgba(image)

				assertEquals(image.data[0], 1)
				assertEquals(image.data[1], 2)
				assertEquals(image.data[2], 3)
				assertEquals(image.data[3], 4)
				assertEquals(image.data[4], 5)
				assertEquals(image.data[5], 6)
				assertEquals(image.data[6], 7)
				assertEquals(image.data[7], 8)
			end)
		end)

		describe("replace_pixel_color_rgba", function()
			it("should replace all pixels of the given color", function()
				local image = ffi.new("stbi_image_t")
				local originalBitmapContents =
					C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
				stbi.bindings.stbi_load_rgba(originalBitmapContents, #originalBitmapContents, image)

				local sourceColor = ffi.new("stbi_color_t", { 0, 0, 255, 255 })
				local replacementColor = ffi.new("stbi_color_t", { 255, 0, 0, 255 })
				stbi.bindings.stbi_replace_pixel_color_rgba(image, sourceColor, replacementColor)

				local expectedPixels = {
					255,
					0,
					0,
					255,
					255,
					0,
					0,
					255,
					255,
					0,
					0,
					255,
					255,
					0,
					0,
					255,
					255,
					0,
					0,
					255,
					255,
					0,
					0,
					255,
				}

				local BYTES_PER_PIXEL = 4 -- RGBA
				for i = 0, image.width * image.height * BYTES_PER_PIXEL - 1 do
					assertEquals(image.data[i], expectedPixels[i + 1])
				end
			end)
		end)
	end)

	describe("version", function()
		it("should be a semantic version string", function()
			local versionString = stbi.version()
			local major, minor, patch = string.match(versionString, "(%d+).(%d+).(%d+)")

			assertEquals(type(major), "string")
			assertEquals(type(minor), "string")
			assertEquals(type(patch), "string")
		end)
	end)
end)
