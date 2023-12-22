local ffi = require("ffi")
local stbi = require("stbi")
local transform = require("transform")

local format = format
local ffi_copy =  ffi.copy
local ffi_gc = ffi.gc
local ffi_new = ffi.new
local math_sqrt = math.sqrt
local transform_bold = transform.bold

local Image = {
	PIXEL_FORMAT_UNKNOWN = stbi.COLOR_DEPTHS.NO_CONVERSION,
	PIXEL_FORMAT_MONOCHROME = stbi.COLOR_DEPTHS.CONVERT_TO_GREYSCALE,
	PIXEL_FORMAT_MONOCHROME_WITH_ALPHA = stbi.COLOR_DEPTHS.CONVERT_TO_GREYSCALE_WITH_ALPHA,
	PIXEL_FORMAT_RGB = stbi.COLOR_DEPTHS.CONVERT_TO_RGB,
	PIXEL_FORMAT_RGBA = stbi.COLOR_DEPTHS.CONVERT_TO_RGB_WITH_ALPHA,
	PIXEL_FORMAT_NAMES = {
		[0]="Unknown (use source format)",
		[1]="Monochrome (no alpha channel)",
		[2]="Monochrome (with alpha channel)",
		[3]="RGB",
		[4]="RGBA",
	}
}

Image.DEFAULT_PIXEL_FORMAT = Image.PIXEL_FORMAT_RGBA

function Image:__tostring()
	local pixelArraySizeInBytes = self.width * self.height * self.colorDepthBitsPerPixel
	local formatted = {
		width = format("%df", self.width),
		height = format("%d", self.height),
		bitsPerPixel = format("%d", self.colorDepthBitsPerPixel),
		fileSize = format("%d", pixelArraySizeInBytes),
	}
	local firstRow = format("%10s %10s %10s", formatted.x, formatted.y, formatted.z)
	return format("%s\n%s", transform_bold("cdata<Image>:"), firstRow)
end

function Image:Construct(width, height, pixelArray, pixelFormat)

	local instance = {
		width = width,
		height = height,
		-- TODO GC anchor pixelArray
		pixelFormat = pixelFormat or Image.DEFAULT_PIXEL_FORMAT, -- TODO assert default is RGBA
	}
-- 	error("Called Construct")
-- 	local image = ffi_new("stbi_image_t")
-- 	image.width = width
-- 	image.height = height
-- 	image.channels = pixelFormat or 4


-- 	if type(pixelArray) == "string" then

-- 		error("WOOT?", 0)
-- 		-- No way around this allocation?
-- 			   local dataSize = width * height * pixelFormat
-- 			   local buffer = ffi_new("stbi_unsigned_char_t[?]", dataSize)
	   
-- 			   ffi_copy(buffer, pixelArray, #pixelArray)
	   
-- 			   image.data = buffer
	   
-- 			   ffi_gc(image, function(img)
-- 				print("[Image] Finalizer called")
-- 				   ffi.free(img.data) -- TBD stbi_image_free?
-- 			   end)
		
		
-- 		-- pixelArray = buffer.new(#pixelArray):put(pixelArray):ref()
-- 		-- TODO GC anchor?

-- 			else
-- 				error("Unsupported pixel array type", 0)
-- 				image.data = pixelArray

-- 	end

-- 	-- ffi_gc(image, stbi.bindings.stbi_image_free(image))
-- 	return image

return instance
end

Image.__index = Image
Image.__call = Image.Construct
setmetatable(Image, Image)

return Image
