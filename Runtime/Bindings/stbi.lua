local bindings = require("bindings")
local ffi = require("ffi")

local stbi = {
	COLOR_DEPTHS = {
		[0] = "NO_CONVERSION",
		[1] = "CONVERT_TO_GREYSCALE",
		[2] = "CONVERT_TO_GREYSCALE_WITH_ALPHA",
		[3] = "CONVERT_TO_RGB",
		[4] = "CONVERT_TO_RGB_WITH_ALPHA",
		NO_CONVERSION = 0,
		CONVERT_TO_GREYSCALE = 1,
		CONVERT_TO_GREYSCALE_WITH_ALPHA = 2,
		CONVERT_TO_RGB = 3,
		CONVERT_TO_RGB_WITH_ALPHA = 4,
	},
}

stbi.cdefs = [[
	// This may be moved to C later if needed, but for now it's Lua only
	typedef struct stbi_color {
		uint8_t red;
		uint8_t green;
		uint8_t blue;
		uint8_t alpha;
	} stbi_color_t;

]] .. bindings.stbi.cdefs

function stbi.initialize()
	ffi.cdef(stbi.cdefs)
end

function stbi.version()
	return ffi.string(stbi.bindings.stbi_version())
end

function stbi.replace_pixel_color_rgba(image, sourceColor, replacementColor)
	local pixelCount = image.width * image.height
	local pixelBuffer = ffi.cast("stbi_color_t*", image.data)

	for i = 0, pixelCount - 1 do
		local pixel = pixelBuffer[i]

		if
			pixel.red == sourceColor.red
			and pixel.green == sourceColor.green
			and pixel.blue == sourceColor.blue
			and pixel.alpha == sourceColor.alpha
		then
			pixelBuffer[i] = replacementColor
		end
	end
end

return stbi
