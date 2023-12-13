local middleclass = require("middleclass")

local oop = {}

function oop.version()
	return string.match(middleclass._VERSION, "middleclass v(.+)")
end

function oop.class(className)
	-- TODO validate string
	return middleclass.class(className)
end

function oop.new(class)
	return class.new(class)
end

return oop