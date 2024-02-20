local console = require("console")
local ffi = require("ffi")
local stbi = require("stbi")

local FIXTURES_DIR = path.join("Tests", "Fixtures")

local SAMPLE_SIZE = 50000000

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

local image = ffi.new("stbi_image_t")
local originalBitmapContents = C_FileSystem.ReadFile(path.join(FIXTURES_DIR, "8bpp-image-without-alpha.bmp"))
stbi.bindings.stbi_load_rgba(originalBitmapContents, #originalBitmapContents, image)

local sourceColor = ffi.new("stbi_color_t", { 0, 0, 255, 255 })
local replacementColor = ffi.new("stbi_color_t", { 255, 0, 0, 255 })

local function replacePixelColorsLua()
	stbi.replace_pixel_color_rgba(image, sourceColor, replacementColor)
end

local function replacePixelColorsFFI()
	stbi.bindings.stbi_replace_pixel_color_rgba(image, sourceColor, replacementColor)
end

math.randomseed(os.clock())
local availableBenchmarks = {
	function()
		local label = "[FFI] Replace pixel colors"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			replacePixelColorsFFI()
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[Lua] Replace pixel colors"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			replacePixelColorsLua()
		end
		console.stopTimer(label)
	end,
}

local function shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

shuffle(availableBenchmarks)

for _, benchmark in ipairs(availableBenchmarks) do
	benchmark()
end
