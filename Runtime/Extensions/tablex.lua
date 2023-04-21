local validation = require("validation")

local ipairs = ipairs

function table.contains(table, value)
	validation.validateTable(table, "table")

	for _, v in ipairs(table) do
		if v == value then
			return true
		end
	end

	return false
end
