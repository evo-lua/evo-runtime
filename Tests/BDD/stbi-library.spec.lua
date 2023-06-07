local ffi = require("ffi")
local stbi = require("stbi")

local FIXTURES_DIR = path.join("Tests", "Fixtures")

describe("stbi", function()
	describe("bindings", function()
		it("should export the entirety of the stbi API", function()
			local exportedApiSurface = {
				"stbi_version",
				"stbi_image_info",
				"stbi_load_image",
				"stbi_image_free",
				"stbi_encode_bmp",
				"stbi_encode_png",
				"stbi_encode_jpg",
				"stbi_encode_tga",
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

		describe("stbi_encode_bmp", function()
			local fileContents = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
			local image = ffi.new("stbi_image_t")
			local result = buffer.new()
			it("should return the encoded file length after storing the pixel data", function()
				stbi.bindings.stbi_load_image(fileContents, #fileContents, image)

				local decodedPixelData = ffi.string(image.data, image.width * image.height * image.channels)

				local maxFileSize = stbi.max_bitmap_size(image.width, image.height, image.channels)
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

				local maxFileSize = stbi.max_bitmap_size(image.width, image.height, image.channels)
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

				local maxFileSize = stbi.max_bitmap_size(image.width, image.height, image.channels)
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

				local maxFileSize = stbi.max_bitmap_size(image.width, image.height, image.channels)
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
	end)

	describe("max_bitmap_size", function()
		it("should return the maximum bitmap size for a simple BMP file", function()
			local maxBitmapSize = stbi.max_bitmap_size(256, 256, 3)
			assertEquals(maxBitmapSize, 196662)
		end)

		it("should reserve enough space for JPG section overhead if the image is small", function()
			local maxBitmapSize = stbi.max_bitmap_size(2, 3, 3)
			assertEquals(maxBitmapSize, 1024)
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
