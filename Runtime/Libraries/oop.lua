local middleclass = require("middleclass")

local oop = {
	registeredClasses = {},
}

function oop.version()
	return string.match(middleclass._VERSION, "middleclass v(.+)")
end

function oop.class(className)
	-- TODO validate string
	if oop.registeredClasses[className] then
		error(format("Failed to register class %s (a class with this name already exists)", className), 0)
	end

	local class = middleclass.class(className)
	oop.registeredClasses[className] = class
	-- local mt = getmetatable(class)
	-- mt.__call = function(self, ...)
	-- 	return self:Construct(...)
	-- end
	-- function class:initialize(...)
	-- 	return self:Construct(...)
	-- end

	return class
end

function oop.new(class)
	local instance = class.new(class)
	function instance:initialize(...)
		return instance:Construct(...)
	end
	return instance
end

return oop