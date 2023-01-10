local transform = {
	ENABLE_TEXT_TRANSFORMATIONS = true,
	START_SEQUENCE = "\27[",
	RESET_SEQUENCE = "\27[0;0m",
	colorCodes = {
		bold = "0;1m",
		underline = "0;4m",
		green = "0;32m",
		gray = "1;30m",
		white = "1;37m",
		black = "1;30m",
		red = "0;31m",
		cyan = "0;96m",
		yellow = "0;33m",
		brightRed = "0;91m",
		brightRedBackground = "0;101m",
		blackBackground = "0;40m",
		greenBackground = "0;42m",
		whiteBackground = "0;47m",
	},
}

local type = type

function transform.enable()
	transform.ENABLE_TEXT_TRANSFORMATIONS = true
end

function transform.disable()
	transform.ENABLE_TEXT_TRANSFORMATIONS = false
end

local function transformText(text, color)
	if type(text) ~= "string" then
		error("Usage: transform." .. color .. "(text : string)", 0)
	end

	if not transform.ENABLE_TEXT_TRANSFORMATIONS then
		return text
	end

	local code = transform.colorCodes[color]
	return transform.START_SEQUENCE .. code .. text .. transform.RESET_SEQUENCE
end

for color, code in pairs(transform.colorCodes) do
	transform[color] = function(text)
		return transformText(text, color)
	end
end

return transform
