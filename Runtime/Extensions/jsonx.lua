local json = require("json")

local json_decode = json.decode
local json_encode = json.encode

json.parse = json_decode
json.stringify = json_encode

function json.pretty(jsonStringOrTable)
	local encodingOptions = {
		pretty = true,
		sort_keys = true,
	}

	if type(jsonStringOrTable) == "string" then
		return json_encode(json.decode(jsonStringOrTable), encodingOptions)
	end

	if type(jsonStringOrTable) == "table" then
		return json_encode(jsonStringOrTable, encodingOptions)
	end

	return nil, "string or table expected, got " .. type(jsonStringOrTable)
end

function json.prettier(jsonStringOrTable)
	local encodingOptions = {
		prettier = true,
		sort_keys = true,
	}

	if type(jsonStringOrTable) == "string" then
		return json_encode(json.decode(jsonStringOrTable), encodingOptions)
	end

	if type(jsonStringOrTable) == "table" then
		return json_encode(jsonStringOrTable, encodingOptions)
	end

	return nil, "string or table expected, got " .. type(jsonStringOrTable)
end
