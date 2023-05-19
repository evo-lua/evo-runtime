local json = require("json")

local json_decode = json.decode
local json_encode = json.encode
local string_match = string.match

function json.version()
	return string_match(json._VERSION, "v(%d+.%d+.%d+)") -- Strip the leading v
end

function json.parse(jsonString)
	return json_decode(jsonString)
end

function json.stringify(luaTable)
	return json_encode(luaTable)
end

function json.pretty(jsonStringOrTable)
	local encodingOptions = {
		pretty = true,
		sort_keys = true,
	}

	if type(jsonStringOrTable) == "string" then
		return json.encode(json.decode(jsonStringOrTable), encodingOptions)
	end

	if type(jsonStringOrTable) == "table" then
		return json.encode(jsonStringOrTable, encodingOptions)
	end

	return nil, "string or table expected, got " .. type(jsonStringOrTable)
end

function json.prettier(jsonStringOrTable)
	local encodingOptions = {
		prettier = true,
		sort_keys = true,
	}

	if type(jsonStringOrTable) == "string" then
		return json.encode(json.decode(jsonStringOrTable), encodingOptions)
	end

	if type(jsonStringOrTable) == "table" then
		return json.encode(jsonStringOrTable, encodingOptions)
	end

	return nil, "string or table expected, got " .. type(jsonStringOrTable)
end
