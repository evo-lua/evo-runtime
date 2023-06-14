local regex = require("regex")

describe("regex", function()
	local exportedFunctions = {
		"config",
		"count",
		"find",
		"flags",
		"gmatch",
		"gsub",
		"maketables",
		"match",
		"new",
		"split",
		"version",
	}

	it("should export all PCRE2 functions", function()
		for _, functionName in ipairs(exportedFunctions) do
			local exportedFunction = regex[functionName]
			assertEquals(type(exportedFunction), "function", "Should export function " .. functionName)
		end
	end)

	describe("version", function()
		it("should return the embedded PCRE2 version in its original format", function()
			local embeddedPcre2Version = regex.version()
			local major, minor = string.match(embeddedPcre2Version, "^(%d+)%.(%d+)")
			local semanticVersionString = major .. "." .. minor .. "." .. 0
			assertEquals(type(string.match(semanticVersionString, "%d+.%d+.%d+")), "string")
		end)
	end)

	local subj = "We go to school"
	local patt = "(\\w+)\\s+(\\w+)"
	local repl = "%2 %1"

	describe("find", function()
		it("should return all captures and indices if the pattern matches the subject", function()
			local from, to, cap1, cap2 = regex.find(subj, patt)
			assertEquals(from, 1)
			assertEquals(to, 5)
			assertEquals(cap1, "We")
			assertEquals(cap2, "go")
		end)
	end)

	describe("gsub", function()
		it("should return the altered subject if both search and replacement patterns match", function()
			local result = regex.gsub(subj, patt, repl)
			assertEquals(result, "go We school to")
		end)
	end)

	describe("gmatch", function()
		it("should return an iterator for all matches if the pattern matches the subject", function()
			local string = "The red frog sits on the blue box in the green well."
			local colors = {}
			for color in regex.gmatch(string, "(red|blue|green)") do
				colors[#colors + 1] = color
			end
			assertEquals(#colors, 3)
		end)
	end)
end)
