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
