local validation = require("validation")

local ipairs = ipairs
local pairs = pairs
local type = type

function table.contains(table, value)
	validation.validateTable(table, "table")

	for _, v in ipairs(table) do
		if v == value then
			return true
		end
	end

	return false
end

function table.count(object)
	local count = 0

	for k, v in pairs(object) do
		-- cdata can trip up nil checks, so it's best to be explicit here
		if type(v) ~= "nil" then
			count = count + 1
		end
	end

	return count
end
