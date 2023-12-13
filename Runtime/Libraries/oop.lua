local middleclass = require("middleclass")

local oop = {}

function oop.version()
	return string.match(middleclass._VERSION, "middleclass v(.+)")
end

function oop.class(className)
	-- TODO validate string
	local class = middleclass.class(className)
	-- local mt = getmetatable(class)
	-- mt.__call = function(self, ...)
	-- 	return self:Construct(...)
	-- end
	return class
end

function oop.new(class)
	return class.new(class)
end

return oop