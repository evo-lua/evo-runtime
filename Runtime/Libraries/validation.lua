local ffi = require("ffi")

local error = error
local format = string.format
local type = type

local validation = {}

function validation.validateString(value, name)
	if type(value) ~= "string" then
		error(
			format(
				"Expected argument %s to be a %s value, but received a %s value instead",
				name,
				"string",
				type(value)
			),
			0
		)
	end
end

function validation.validateNumber(value, name)
	if type(value) ~= "number" then
		error(
			format(
				"Expected argument %s to be a %s value, but received a %s value instead",
				name,
				"number",
				type(value)
			),
			0
		)
	end
end

function validation.validateBoolean(value, name)
	if type(value) ~= "boolean" then
		error(
			format(
				"Expected argument %s to be a %s value, but received a %s value instead",
				name,
				"boolean",
				type(value)
			),
			0
		)
	end
end

function validation.validateTable(value, name)
	if type(value) ~= "table" then
		error(
			format("Expected argument %s to be a %s value, but received a %s value instead", name, "table", type(value)),
			0
		)
	end
end

function validation.validateFunction(value, name)
	if type(value) ~= "function" then
		error(
			format(
				"Expected argument %s to be a %s value, but received a %s value instead",
				name,
				"function",
				type(value)
			),
			0
		)
	end
end

function validation.validateThread(value, name)
	if type(value) ~= "thread" then
		error(
			format(
				"Expected argument %s to be a %s value, but received a %s value instead",
				name,
				"thread",
				type(value)
			),
			0
		)
	end
end

function validation.validateUserdata(value, name)
	if type(value) ~= "userdata" then
		error(
			format(
				"Expected argument %s to be a %s value, but received a %s value instead",
				name,
				"userdata",
				type(value)
			),
			0
		)
	end
end

function validation.validateStruct(value, name)
	if type(value) ~= "cdata" then
		error(
			format("Expected argument %s to be a %s value, but received a %s value instead", name, "cdata", type(value)),
			0
		)
	end
end

function validation.validateExportsTable(exportsTable, cType)
	local numExportedFunctions = ffi.sizeof(cType) / ffi.sizeof("void*")
	local functionPointer = ffi.cast("void**", exportsTable)

	for index = 0, numExportedFunctions - 1, 1 do
		if functionPointer[index] == ffi.NULL then
			return nil, index
		end
	end

	return true, numExportedFunctions
end

return validation
