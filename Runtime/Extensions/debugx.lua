local inspect = require("inspect")

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

debug.dump = dump
