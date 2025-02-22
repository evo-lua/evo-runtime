local inspect = require("inspect")
local vmdef = require("vmdef")

local print = print
local tostring = tostring
local format = string.format
local tinsert = table.insert

local MAX_TABLE_NESTING_LEVEL = 30
local DEFAULT_OPTIONS = {
	depth = MAX_TABLE_NESTING_LEVEL,
	indent = "\t",
	silent = false,
}
local LUAJIT_BUILTIN_TOSTRING_PATTERN = "builtin#(%d+)"
local LUAJIT_BUILTIN_TRACEBACK_PATTERN = "%[builtin#(%d+)%]"

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
	if type(sbuf.ref) ~= "function" then
		-- Not a LuaJIT string buffer
		return tostring(sbuf)
	end

	local hexBytes = {}
	local ptr, len = sbuf:ref()
	for index = 1, len do
		local cIndex = index - 1
		local hexByte = format("%02X", ptr[cIndex])
		local isLastByte = (index == len)
		local optionalComma = isLastByte and "" or ","
		tinsert(hexBytes, hexByte .. optionalComma)
	end

	local isEmpty = (#sbuf == 0)
	local bytes = isEmpty and "" or table.concat(hexBytes, " ")
	return format("%s [%s]", "Buffer", bytes)
end

function debug.tostring(what)
	local stringified = tostring(what)
	stringified = stringified:gsub(LUAJIT_BUILTIN_TOSTRING_PATTERN, function(builtinID)
		return vmdef.ffnames[tonumber(builtinID)]
	end)

	stringified = stringified:gsub(LUAJIT_BUILTIN_TRACEBACK_PATTERN, function(builtinID)
		return vmdef.ffnames[tonumber(builtinID)]
	end)

	return stringified
end

debug.dump = dump
