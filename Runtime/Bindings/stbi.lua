local ffi = require("ffi")

local math_max = math.max

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
	typedef unsigned char stbi_unsigned_char_t;
	typedef unsigned char* stbi_pixelbuffer_t;
	typedef unsigned char const* stbi_readonly_file_contents_t;

	typedef struct stbi_image {
		int width;
		int height;
		stbi_pixelbuffer_t data;
		int channels;
	} stbi_image_t;

	struct static_stbi_exports_table {
		const char* (*stbi_version)(void);

		bool (*stbi_image_info)(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image);
		bool (*stbi_load_image)(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image);
		bool (*stbi_image_free)(stbi_image_t* image);

		bool (*stbi_load_rgb)(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image);
		bool (*stbi_load_rgba)(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image);
		bool (*stbi_load_monochrome)(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image);
		bool (*stbi_load_monochrome_with_alpha)(stbi_readonly_file_contents_t buffer, const size_t file_size, stbi_image_t* image);

		size_t (*stbi_encode_bmp)(stbi_image_t* image, uint8_t* buffer, const size_t buffer_size);
		size_t (*stbi_encode_png)(stbi_image_t* image, uint8_t* buffer, const size_t buffer_size, const int stride);
		size_t (*stbi_encode_jpg)(stbi_image_t* image, uint8_t* buffer, const size_t buffer_size, int quality);
		size_t (*stbi_encode_tga)(stbi_image_t* image, uint8_t* buffer, const size_t buffer_size);

		void (*stbi_flip_vertically_on_write)(int flag);
	};

	// This may be moved to C later if needed, but for now it's Lua only
	typedef struct stbi_color {
		uint8_t red;
		uint8_t green;
		uint8_t blue;
		uint8_t alpha;
	} stbi_color_t;
]]

function stbi.initialize()
	ffi.cdef(stbi.cdefs)
end

function stbi.version()
	return ffi.string(stbi.bindings.stbi_version())
end

local BMP_HEADER_SIZE = 54
local JPEG_OVERHEAD_BUFFER_SIZE = 1024
-- Somewhat sketchy, but should be large enough for all formats
function stbi.max_bitmap_size(width, height, channels)
	local headerSizeInBytes = BMP_HEADER_SIZE
	local pixelSizeInBytes = channels
	local rowSizeInBytes = width * pixelSizeInBytes

	-- Rows are aligned to 4 bytes in BMP format
	local padding = (4 - (rowSizeInBytes % 4)) % 4
	rowSizeInBytes = rowSizeInBytes + padding

	-- This should cover most regular-sized images in all of the supported formats
	local estimatedWorstCaseBitmapFileSize = (headerSizeInBytes + height * rowSizeInBytes)

	-- JPEG-encoded sections add significant overhead if the image is small, so let's account for that
	return math_max(estimatedWorstCaseBitmapFileSize, JPEG_OVERHEAD_BUFFER_SIZE)
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
