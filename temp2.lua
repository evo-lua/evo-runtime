local console = require("console")
local ffi = require("ffi")
local stbi = require("stbi")

local upscaleFactor = 64

local testImage = C_FileSystem.ReadFile("palette.bmp")

-- local imageBuffer = buffer.new(2 * 2 * 4):put("\255\0\0\0\0\255\0\0\0\0\255\0\0\0\0\255")
local imageBuffer = buffer.new():put(C_ImageProcessing.DecodeFileContents(testImage))
local ptr, _ = imageBuffer:ref()

local image = ffi.new("stbi_image_t")
image.data = ptr
image.width = 16
image.height = 16
image.channels = 4

local upscaledImageBuffer = buffer.new()
local ptr2, len = upscaledImageBuffer:reserve(16 * 16 * 4 * upscaleFactor * upscaleFactor)

local upscaledWidth = image.width * upscaleFactor
local upscaledHeight = image.height * upscaleFactor

local upscaledImage = ffi.new("stbi_image_t")
upscaledImage.width = upscaledWidth
upscaledImage.height = upscaledHeight
upscaledImage.channels = image.channels
upscaledImage.data = ptr2

console.startTimer("Neared neighbor resize")
stbi.bindings.stbi_nearest_neighbor_resize(image, upscaledImage)
console.stopTimer("Neared neighbor resize")

upscaledImageBuffer:commit(len)

-- print(#upscaledImageBuffer, upscaledWidth, upscaledHeight, tostring(upscaledImageBuffer))
local bmpFileContents = C_ImageProcessing.EncodeBMP(tostring(upscaledImageBuffer), upscaledWidth, upscaledHeight)

C_FileSystem.WriteFile("upscaled-" .. upscaleFactor .. "x.bmp", bmpFileContents)
