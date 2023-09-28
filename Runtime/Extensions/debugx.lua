local inspect = require("inspect")
local transform = require("transform")

local print = print
local format = string.format
local tinsert = table.insert

local MAX_TABLE_NESTING_LEVEL = 30
local DEFAULT_OPTIONS = {
	depth = MAX_TABLE_NESTING_LEVEL,
	indent = "\t",
	silent = false,
}

local function dump(object, options)
	if type(object) == "userdata" then
		local hexBytes = debug.sbuf(object)
		print(hexBytes)
		return hexBytes
	end

	options = options or DEFAULT_OPTIONS
	local dumpValue = inspect(object, options)
	if not options.silent then
		print(dumpValue)
	end
	return dumpValue
end

function debug.sbuf(sbuf)
	local hexBytes = {}
	local ptr, len = sbuf:ref()
	for i = 1, len do
		tinsert(hexBytes, string.format("%02x", ptr[i - 1])) -- 0-based C index
	end

	local isEmpty = (#sbuf == 0)
	local bytes = isEmpty and "" or table.concat(hexBytes, " ")
	return format("%s %s", transform.bold("userdata<Buffer>:"), bytes)
end

debug.dump = dump
