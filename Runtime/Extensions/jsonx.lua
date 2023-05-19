local json = require("json")

local string_match = string.match

function json.version()
	return string_match(json._VERSION, "v(%d+.%d+.%d+)") -- Strip the leading v
end
