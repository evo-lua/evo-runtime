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

function stbi.initialize()
	ffi.cdef(bindings.stbi.cdefs)
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
