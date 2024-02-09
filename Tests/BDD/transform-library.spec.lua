local transform = require("transform")

local supportedTerminalColors = {
	"black",
	"red",
	"green",
	"yellow",
	"blue",
	"magenta",
	"cyan",
	"white",
	"gray",
	"brightRed",
	"brightGreen",
	"brightYellow",
	"brightBlue",
	"brightMagenta",
	"brightCyan",
	"brightWhite",
	"blackBackground",
	"redBackground",
	"greenBackground",
	"yellowBackground",
	"blueBackground",
	"magentaBackground",
	"cyanBackground",
	"whiteBackground",
	"brightRedBackground",
	"brightGreenBackground",
	"brightYellowBackground",
	"brightBlueBackground",
	"brightMagentaBackground",
	"brightCyanBackground",
	"brightWhiteBackground",
	"bold",
	"underline",
	"blink",
	"reverse",
}

describe("transform", function()
	it("should be set to apply color codes by default", function()
		assertTrue(transform.ENABLE_TEXT_TRANSFORMATIONS)
	end)

	it("should support applying all valid color codes if text transformations are enabled", function()
		for _, color in ipairs(supportedTerminalColors) do
			local text = "hello"
			local coloredText = transform[color](text)
			assertEquals(
				coloredText,
				transform.START_SEQUENCE .. transform.colorCodes[color] .. text .. transform.RESET_SEQUENCE
			)
		end
	end)

	it("should not modify the input if text transformations are disabled", function()
		transform.disable()

		for _, color in ipairs(supportedTerminalColors) do
			local text = "hello"
			local coloredText = transform[color](text)
			assertEquals(coloredText, text)
		end

		transform.enable()
	end)

	it("should raise an error if a non-string value is passed", function()
		local ffi = require("ffi")

		local invalidValues = {
			42,
			{},
			function() end,
			ffi.new("uint8_t"),
		}
		for _, color in ipairs(supportedTerminalColors) do
			for _, invalidValue in ipairs(invalidValues) do
				local actualType = type(invalidValue)
				assertThrows(function()
					transform[color](invalidValue)
				end, format(
					"Expected argument text to be a string value, but received a %s value instead",
					actualType
				))
			end
		end
	end)

	describe("enable", function()
		it("should enable the injection of color codes if they've previously been disabled", function()
			transform.ENABLE_TEXT_TRANSFORMATIONS = false
			assertFalse(transform.ENABLE_TEXT_TRANSFORMATIONS)

			transform.enable()

			assertTrue(transform.ENABLE_TEXT_TRANSFORMATIONS)
		end)
	end)

	describe("disable", function()
		it("should disable the injection of color codes if they've previously been enabled", function()
			assertTrue(transform.ENABLE_TEXT_TRANSFORMATIONS)

			transform.disable()
			assertFalse(transform.ENABLE_TEXT_TRANSFORMATIONS)

			-- Restore the default setting
			transform.ENABLE_TEXT_TRANSFORMATIONS = true
		end)
	end)

	describe("strip", function()
		it("should throw if a non-string value was passed", function()
			assertThrows(function()
				transform.strip(42)
			end, "Expected argument coloredConsoleText to be a string value, but received a number value instead")
		end)

		it("should remove color codes from the input without otherwise modifying it", function()
			for name, transformation in pairs(transform) do
				if type(transformation) == "function" and transform.colorCodes[name] then
					local originalText = "Hello world"
					local coloredText = transform.brightYellow(originalText)
					assertEquals(transform.strip(coloredText), originalText)
				end
			end
		end)
	end)
end)
