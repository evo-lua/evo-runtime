local validation = require("validation")

local ipairs = ipairs
local pairs = pairs
local type = type

local table_insert = table.insert

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

function table.copy(source)
	local deepCopy = {}

	for key, value in pairs(source) do
		if type(value) == "table" then
			deepCopy[key] = table.copy(value)
		else
			deepCopy[key] = value
		end
	end

	return deepCopy
end

function table.scopy(source)
	local shallowCopy = {}

	for key, value in pairs(source) do
		shallowCopy[key] = value
	end

	return shallowCopy
end

function table.reverse(tableToReverse)
	validation.validateTable(tableToReverse, "tableToReverse")

	local reversedTable = {}

	for index, value in ipairs(tableToReverse) do
		local reversedIndex = #tableToReverse - index + 1
		reversedTable[reversedIndex] = value
	end

	return reversedTable
end

function table.invert(tableToInvert)
	validation.validateTable(tableToInvert, "tableToInvert")

	local invertedTable = {}
	for key, value in pairs(tableToInvert) do
		invertedTable[value] = key
	end

	return invertedTable
end

function table.keys(table)
	validation.validateTable(table, "table")

	local keys = {}
	for key, value in pairs(table) do
		table_insert(keys, key)
	end

	return keys
end

function table.values(table)
	validation.validateTable(table, "table")

	local values = {}
	for key, value in pairs(table) do
		table_insert(values, value)
	end

	return values
end

table.clear = require("table.clear")
table.new = require("table.new")
