local validation = require("validation")

local setmetatable = setmetatable
local type = type

local validateString = validation.validateString
local validateTable = validation.validateTable

local oop = {
	registeredClasses = {},
	errorStrings = {
		DUPLICATE_CLASS_NAME = "Class name %s is already registered",
		MIXIN_WOULD_OVERWRITE = "Mixing in %s would overwrite property %s on the target",
	},
}

local function makeDefaultConstructor(class)
	return function(cls, ...)
		local instance = {}
		local inheritanceLookupMetatable = {
			__index = cls,
		}
		setmetatable(instance, inheritanceLookupMetatable)
		return instance
	end
end

function oop.class(classNameToRegister, existingClassPrototype)
	validateString(classNameToRegister, "classNameToRegister")
	if existingClassPrototype ~= nil then
		validateTable(existingClassPrototype, "existingClassPrototype")
	end

	if oop.registeredClasses[classNameToRegister] ~= nil then
		error(string.format(oop.errorStrings.DUPLICATE_CLASS_NAME, classNameToRegister), 0)
	end

	local class = existingClassPrototype or {}
	class.Construct = class.Construct or makeDefaultConstructor(class)
	class.__name = classNameToRegister

	local inheritanceLookupMetatable = {
		__call = class.Construct,
		__index = class,
	}
	setmetatable(class, inheritanceLookupMetatable)

	oop.registeredClasses[classNameToRegister] = class
	return class
end

function oop.classname(classOrInstance)
	validateTable(classOrInstance, "classOrInstance")

	local isConstructedInstanceOfRegisteredClass = type(classOrInstance.__name) == "string"
		and oop.registeredClasses[classOrInstance.__name] ~= nil
	if isConstructedInstanceOfRegisteredClass then
		return classOrInstance.__name
	end

	local mt = getmetatable(classOrInstance)
	local name = mt and rawget(mt, "__name")
	local isPrototypeOfRegisteredClass = name and oop.registeredClasses[name] ~= nil
	if isPrototypeOfRegisteredClass then
		return mt.__name
	end
end

function oop.instanceof(instance, instanceOrPrototype)
	validateTable(instance, "instance")
	if type(instanceOrPrototype) == "string" then
		instanceOrPrototype = oop.registeredClasses[instanceOrPrototype]
	end
	validateTable(instanceOrPrototype, "instanceOrPrototype")

	-- To keep thing simple, inheritance chains aren't supported (for now)
	return oop.classname(instance) == oop.classname(instanceOrPrototype)
end

function oop.extend(child, parent)
	validateTable(child, "child")
	validateTable(parent, "parent")

	local childMetatable = getmetatable(child)
	childMetatable.__index = parent

	child.super = parent

	return child
end

function oop.mixin(target, ...)
	validateTable(target, "target")

	local tablesToMixIn = { ... }
	for index, sourceObject in pairs(tablesToMixIn) do
		validateTable(sourceObject, "sourceObject" .. index)
		for key, value in pairs(sourceObject) do
			if target[key] ~= nil then
				error(format(oop.errorStrings.MIXIN_WOULD_OVERWRITE, "sourceObject" .. index, key), 0)
			end
			target[key] = value
		end
	end
end

return oop
