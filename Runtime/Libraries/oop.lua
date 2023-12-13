local middleclass = require("middleclass")

local oop = {}

function oop:version()
	return string.match(middleclass._VERSION, "middleclass v(.+)")
end

return oop