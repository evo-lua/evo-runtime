local transform = require("transform")
local transform_green = transform.green
local transform_red = transform.red

local validation = require("validation")
local validateString = validation.validateString

local ipairs = ipairs
local format = string.format
local math_floor = math.floor
local math_pow = math.pow
local math_log10 = math.log10
local string_gmatch = string.gmatch
local table_concat = table.concat
local table_insert = table.insert

local TOKENS_SEPARATED_BY_NEWLINES_PATTERN = "[^\n]+"
local SKIP_AFTER_FIRST_DIFFERENCE = true -- The changesets will get out of whack because this algorithm is too simple otherwise

local function diffByLines(before, after)
	validateString(before, "before")
	validateString(after, "after")

	local lines = {}

	local beforeTokens = {}
	local afterTokens = {}
	for line in before:gmatch(TOKENS_SEPARATED_BY_NEWLINES_PATTERN) do
		table_insert(beforeTokens, line)
	end

	for line in after:gmatch(TOKENS_SEPARATED_BY_NEWLINES_PATTERN) do
		table_insert(afterTokens, line)
	end

	for lineNumber, lineBefore in ipairs(beforeTokens) do
		local lineAfter = afterTokens[lineNumber]
		if lineBefore ~= lineAfter then
			table_insert(lines, transform_red("- " .. lineBefore))
			table_insert(lines, transform_green("+ " .. lineAfter))

			-- If we continue here, some lines might get eaten. There's not much of a point, either...
			local hasMoreLines = (lineNumber < #beforeTokens)
			if SKIP_AFTER_FIRST_DIFFERENCE and hasMoreLines then
				table_insert(lines, "  ... (additional lines skipped)")
				return table_concat(lines, "\n")
			end
		else
			table_insert(lines, "  " .. lineBefore)
		end
	end

	return table_concat(lines, "\n")
end

function string.diff(firstValue, secondValue)
	return diffByLines(firstValue, secondValue)
end

function string.explode(inputString, delimiter)
	validateString(inputString, "inputString")
	delimiter = delimiter or "%s"
	validateString(delimiter, "delimiter")

	local tokens = {}
	for token in string_gmatch(inputString, "([^" .. delimiter .. "]+)") do
		table_insert(tokens, token)
	end
	return tokens
end

function string.filesize(size)
	if size <= 0 then -- Negative file sizes don't make any sense
		return "0 bytes"
	end

	local units = { "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB" }
	local digitGroup = math_floor(math_log10(size) / math_log10(1024))

	if digitGroup == 0 then
		return size .. " bytes"
	elseif digitGroup == 1 then
		return format("%d %s", size / math_pow(1024, digitGroup), units[digitGroup + 1])
	else
		return format("%.2f %s", size / math_pow(1024, digitGroup), units[digitGroup + 1])
	end
end
