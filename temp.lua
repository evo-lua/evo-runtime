local console = require("console")
local ffi = require("ffi")
local stbi = require("stbi")

local originalImage = ffi.new("stbi_image_t")
originalImage.data = buffer.new(2 * 2 * 4):put("\255\0\0\0\0\255\0\0\0\0\255\0\0\0\0\255")
originalImage.width = 2
originalImage.height = 2
originalImage.channels = 4

local resizeFactor = 256

local resizedImage = ffi.new("stbi_image_t")
resizedImage.width = resizeFactor
resizedImage.height = resizeFactor
resizedImage.channels = 4
resizedImage.data = buffer.new(resizeFactor * resizeFactor * 4)

console.startTimer("stbi_resize_filtered")
stbi.bindings.stbi_resize_filtered(originalImage, resizedImage)
console.stopTimer("stbi_resize_filtered")

C_FileSystem.WriteFile("original.bmp", C_ImageProcessing.EncodeBMP(ffi.string(originalImage.data, 2 * 2 * 4), 2, 2))
C_FileSystem.WriteFile(
	"resized.bmp",
	C_ImageProcessing.EncodeBMP(
		ffi.string(resizedImage.data, resizeFactor * resizeFactor * 4),
		resizeFactor,
		resizeFactor
	)
)

-- assertEquals(resizedImage.data[0], 1)
-- assertEquals(resizedImage.data[1], 2)
-- assertEquals(resizedImage.data[2], 3)
-- assertEquals(resizedImage.data[3], 4)
-- assertEquals(resizedImage.data[4], 1)
-- assertEquals(resizedImage.data[5], 2)
-- assertEquals(resizedImage.data[6], 3)
-- assertEquals(resizedImage.data[7], 4)
-- assertEquals(resizedImage.data[8], 5)
-- assertEquals(resizedImage.data[9], 6)
-- assertEquals(resizedImage.data[10], 7)
-- assertEquals(resizedImage.data[11], 8)
-- assertEquals(resizedImage.data[12], 5)
-- assertEquals(resizedImage.data[13], 6)
-- assertEquals(resizedImage.data[14], 7)
-- assertEquals(resizedImage.data[15], 8)
