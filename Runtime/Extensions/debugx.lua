local inspect = require("inspect")

local format = string.format
local math_floor = math.floor
local math_pow = math.pow
local math_log10 = math.log10
local print = print

local MAX_TABLE_NESTING_LEVEL = 30
local DEFAULT_OPTIONS = {
	depth = MAX_TABLE_NESTING_LEVEL,
	indent = "\t",
	silent = false,
}

local function dump(object, options)
	options = options or DEFAULT_OPTIONS
	local dumpValue = inspect(object, options)
	if not options.silent then
		print(dumpValue)
	end
	return dumpValue
end

function debug.filesize(size)
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

debug.dump = dump
