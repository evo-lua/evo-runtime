local ffi = require("ffi")
local stbi = require("stbi")
local validation = require("validation")

local assert = assert
local tonumber = tonumber
local tostring = tostring
local type = type

local ffi_new = ffi.new
local ffi_string = ffi.string
local validateNumber = validation.validateNumber
local validateString = validation.validateString

local C_ImageProcessing = {}

function C_ImageProcessing.DecodeFileContents(imageFileContents)
	if type(imageFileContents) == "userdata" then
		imageFileContents = tostring(imageFileContents)
	end
	validateString(imageFileContents, "imageFileContents")

	local image = ffi_new("stbi_image_t")
	local success = stbi.load_rgba(imageFileContents, #imageFileContents, image)
	if not success then
		error("Failed to decode image data (stbi_load_rgba returned NULL)", 0)
	end

	local pixelArray = ffi_string(image.data, image.width * image.height * 4)
	stbi.image_free(image)

	return pixelArray, tonumber(image.width), tonumber(image.height)
end

function C_ImageProcessing.EncodeBMP(rgbaPixelArray, imageWidthInPixels, imageHeightInPixels)
	if type(rgbaPixelArray) == "userdata" then
		rgbaPixelArray = tostring(rgbaPixelArray)
	end

	validateString(rgbaPixelArray, "rgbaPixelArray")
	validateNumber(imageWidthInPixels, "imageWidthInPixels")
	validateNumber(imageHeightInPixels, "imageHeightInPixels")

	local rgbaPixelBuffer = buffer.new(#rgbaPixelArray):put(rgbaPixelArray)

	local image = ffi_new("stbi_image_t")
	image.width = imageWidthInPixels
	image.height = imageHeightInPixels
	image.data = rgbaPixelBuffer
	image.channels = 4

	local requiredBufferSize = stbi.get_required_bmp_size(image)
	local outputBuffer = buffer.new()
	local startPointer, reservedBufferSize = outputBuffer:reserve(requiredBufferSize)

	local numBytesWritten = stbi.encode_bmp(image, startPointer, reservedBufferSize)
	assert(numBytesWritten > 0, "Failed to encode BMP image (preallocated buffer too small?)")
	outputBuffer:commit(numBytesWritten)

	return tostring(outputBuffer)
end

function C_ImageProcessing.EncodePNG(rgbaPixelArray, imageWidthInPixels, imageHeightInPixels)
	local strideInBytes = 0

	if type(rgbaPixelArray) == "userdata" then
		rgbaPixelArray = tostring(rgbaPixelArray)
	end

	validateString(rgbaPixelArray, "rgbaPixelArray")
	validateNumber(imageWidthInPixels, "imageWidthInPixels")
	validateNumber(imageHeightInPixels, "imageHeightInPixels")

	local rgbaPixelBuffer = buffer.new(#rgbaPixelArray):put(rgbaPixelArray)

	local image = ffi_new("stbi_image_t")
	image.width = imageWidthInPixels
	image.height = imageHeightInPixels
	image.data = rgbaPixelBuffer
	image.channels = 4

	local requiredBufferSize = stbi.get_required_png_size(image, strideInBytes)
	local outputBuffer = buffer.new()
	local startPointer, reservedBufferSize = outputBuffer:reserve(requiredBufferSize)

	local numBytesWritten = stbi.encode_png(image, startPointer, reservedBufferSize, strideInBytes)
	assert(numBytesWritten > 0, "Failed to encode PNG image (preallocated buffer too small?)")
	outputBuffer:commit(numBytesWritten)

	return tostring(outputBuffer)
end

function C_ImageProcessing.EncodeJPG(rgbaPixelArray, imageWidthInPixels, imageHeightInPixels)
	local qualityPercentage = 100

	if type(rgbaPixelArray) == "userdata" then
		rgbaPixelArray = tostring(rgbaPixelArray)
	end

	validateString(rgbaPixelArray, "rgbaPixelArray")
	validateNumber(imageWidthInPixels, "imageWidthInPixels")
	validateNumber(imageHeightInPixels, "imageHeightInPixels")

	local rgbaPixelBuffer = buffer.new(#rgbaPixelArray):put(rgbaPixelArray)

	local image = ffi_new("stbi_image_t")
	image.width = imageWidthInPixels
	image.height = imageHeightInPixels
	image.data = rgbaPixelBuffer
	image.channels = 4

	local requiredBufferSize = stbi.get_required_jpg_size(image, qualityPercentage)
	local outputBuffer = buffer.new()
	local startPointer, reservedBufferSize = outputBuffer:reserve(requiredBufferSize)

	local numBytesWritten = stbi.encode_jpg(image, startPointer, reservedBufferSize, qualityPercentage)
	assert(numBytesWritten > 0, "Failed to encode JPG image (preallocated buffer too small?)")
	outputBuffer:commit(numBytesWritten)

	return tostring(outputBuffer)
end

function C_ImageProcessing.EncodeTGA(rgbaPixelArray, imageWidthInPixels, imageHeightInPixels)
	if type(rgbaPixelArray) == "userdata" then
		rgbaPixelArray = tostring(rgbaPixelArray)
	end

	validateString(rgbaPixelArray, "rgbaPixelArray")
	validateNumber(imageWidthInPixels, "imageWidthInPixels")
	validateNumber(imageHeightInPixels, "imageHeightInPixels")

	local rgbaPixelBuffer = buffer.new(#rgbaPixelArray):put(rgbaPixelArray)

	local image = ffi_new("stbi_image_t")
	image.width = imageWidthInPixels
	image.height = imageHeightInPixels
	image.data = rgbaPixelBuffer
	image.channels = 4

	local requiredBufferSize = stbi.get_required_tga_size(image)
	local outputBuffer = buffer.new()
	local startPointer, reservedBufferSize = outputBuffer:reserve(requiredBufferSize)

	local numBytesWritten = stbi.encode_tga(image, startPointer, reservedBufferSize)
	assert(numBytesWritten > 0, "Failed to encode TGA image (preallocated buffer too small?)")
	outputBuffer:commit(numBytesWritten)

	return tostring(outputBuffer)
end

return C_ImageProcessing
