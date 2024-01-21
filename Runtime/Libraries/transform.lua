local transform = {
	ENABLE_TEXT_TRANSFORMATIONS = true,
	START_SEQUENCE = "\27[",
	RESET_SEQUENCE = "\27[0;0m",
	colorCodes = {
		bold = "1m",
		underline = "4m",
		blink = "5m",
		reverse = "7m",
		black = "0;30m",
		red = "0;31m",
		green = "0;32m",
		yellow = "0;33m",
		blue = "0;34m",
		magenta = "0;35m",
		cyan = "0;36m",
		white = "0;37m",
		gray = "1;30m",
		brightRed = "1;31m",
		brightGreen = "1;32m",
		brightYellow = "1;33m",
		brightBlue = "1;34m",
		brightMagenta = "1;35m",
		brightCyan = "1;36m",
		brightWhite = "1;37m",
		blackBackground = "40m",
		redBackground = "41m",
		greenBackground = "42m",
		yellowBackground = "43m",
		blueBackground = "44m",
		magentaBackground = "45m",
		cyanBackground = "46m",
		whiteBackground = "47m",
		brightRedBackground = "101m",
		brightGreenBackground = "102m",
		brightYellowBackground = "103m",
		brightBlueBackground = "104m",
		brightMagentaBackground = "105m",
		brightCyanBackground = "106m",
		brightWhiteBackground = "107m",
	},
}

local type = type

function transform.enable()
	transform.ENABLE_TEXT_TRANSFORMATIONS = true
end

function transform.disable()
	transform.ENABLE_TEXT_TRANSFORMATIONS = false
end

function transform.strip(coloredConsoleText)
	if type(coloredConsoleText) ~= "string" then
		error("Usage: transform.strip(text : string)", 0)
	end

	-- All credit goes to this fine gentleman: https://stackoverflow.com/users/3735873/tonypdmtr
	local strippedConsoleText = coloredConsoleText
		:gsub("\027%[%d+;%d+;%d+;%d+;%d+m", "")
		:gsub("\027%[%d+;%d+;%d+;%d+m", "")
		:gsub("\027%[%d+;%d+;%d+m", "")
		:gsub("\027%[%d+;%d+m", "")
		:gsub("\027%[%d+m", "")

	return strippedConsoleText
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
