local debug = require("debug")
local ffi = require("ffi")

local error = error
local pairs = pairs
local pcall = pcall
local tostring = tostring
local type = type
local format = string.format
local debug_getinfo = debug.getinfo
local debug_sethook = debug.sethook
local ffi_string = ffi.string

local assertions = {}

function assertions.assertTrue(conditionToCheck)
	if conditionToCheck == true then
		return true
	end

	error("ASSERTION FAILURE: " .. tostring(conditionToCheck) .. " should be true", 0)
end

function assertions.assertFalse(conditionToCheck)
	if conditionToCheck == false then
		return true
	end

	error("ASSERTION FAILURE: " .. tostring(conditionToCheck) .. " should be false", 0)
end

function assertions.assertNil(conditionToCheck)
	if conditionToCheck == nil then
		return true
	end

	error("ASSERTION FAILURE: " .. tostring(conditionToCheck) .. " should be nil", 0)
end

function assertions.assertThrows(codeUnderTest, expectedErrorMessage)
	local success, errorMessage = pcall(codeUnderTest)

	if success == true then
		error("ASSERTION FAILURE: Function did not raise an error", 0)
	end

	if errorMessage ~= expectedErrorMessage then
		error(
			'ASSERTION FAILURE: Thrown error "'
				.. tostring(errorMessage)
				.. '" should be "'
				.. tostring(expectedErrorMessage)
				.. '"',
			0
		)
	end
end

function assertions.assertDoesNotThrow(codeUnderTest)
	local success, errorMessage = pcall(codeUnderTest)
	if not success then
		error("ASSERTION FAILURE: Expected function to not throw an error but it threw " .. tostring(errorMessage), 0)
	end

	return true
end

function assertions.assertFailure(codeUnderTest, expectedErrorMessage)
	local success, status, value = pcall(codeUnderTest)
	if not success then
		error("ASSERTION FAILURE: Expected a failure but got an error", 0)
	end

	if status ~= nil then
		error(format("ASSERTION FAILURE: Expected a failure but got success with value %s", tostring(value)), 0)
	end

	if expectedErrorMessage and value ~= expectedErrorMessage then
		error(
			format(
				"ASSERTION FAILURE: Expected failure message '%s' but got '%s'",
				tostring(expectedErrorMessage),
				tostring(value)
			),
			0
		)
	end
end

function assertions.assertCallsFunction(codeUnderTest, targetFunction)
	local calledFn = nil
	local function hook(event)
		local calledFunction = debug_getinfo(2, "f").func
		if calledFunction == targetFunction then
			calledFn = calledFunction
		end
	end
	debug_sethook(hook, "c")
	codeUnderTest()
	debug_sethook()
	if calledFn ~= targetFunction then
		error("ASSERTION FAILURE: Expected function " .. tostring(targetFunction) .. " to be called but it was not", 0)
	end
end

local function assertEqualLuaString(firstValue, secondValue)
	if firstValue ~= secondValue then
		error("ASSERTION FAILURE: Expected " .. secondValue .. " but got " .. firstValue)
	end
	return true
end

local function assertEqualBuffer(firstValue, secondValue)
	local firstString = ffi_string(firstValue)
	local secondString = ffi_string(secondValue)
	if firstString ~= secondString then
		error("ASSERTION FAILURE: Expected " .. secondString .. " but got " .. firstString)
	end
	return true
end

function assertions.assertEqualStrings(firstValue, secondValue)
	if type(firstValue) == "string" and type(secondValue) == "string" then
		return assertEqualLuaString(firstValue, secondValue)
	elseif type(firstValue) == "cdata" and type(secondValue) == "cdata" then
		return assertEqualBuffer(firstValue, secondValue)
	elseif type(firstValue) == "string" and type(secondValue) == "cdata" then
		local firstString = ffi_string(firstValue)
		local secondString = ffi_string(secondValue)
		return assertEqualLuaString(firstString, secondString)
	elseif type(firstValue) == "cdata" and type(secondValue) == "string" then
		local firstString = ffi_string(firstValue)
		return assertEqualLuaString(firstString, secondValue)
	else
		return nil
	end
end

function assertions.assertEqualNumbers(firstValue, secondValue, delta)
	if type(firstValue) ~= "number" or type(secondValue) ~= "number" then
		error("ASSERTION FAILURE: Expected numbers but got " .. type(firstValue) .. " and " .. type(secondValue), 0)
	elseif delta then
		local difference = math.abs(firstValue - secondValue)
		if difference > delta then
			error(
				"ASSERTION FAILURE: Expected "
					.. tostring(secondValue)
					.. " but got "
					.. tostring(firstValue)
					.. " within delta "
					.. tostring(delta),
				0
			)
		end
	elseif firstValue ~= secondValue then
		error("ASSERTION FAILURE: Expected " .. tostring(secondValue) .. " but got " .. tostring(firstValue), 0)
	end
	return true
end

local diff = string.diff
local dump = debug.dump

local diffOptions = {
	silent = true,
	separator = "\t",
}

local function computeDiffString(firstValue, secondValue)
	return diff(dump(firstValue, diffOptions), dump(secondValue, diffOptions))
end

function assertions.assertEqualTables(firstValue, secondValue)
	-- Custom comparison for mixed types
	local function compare(a, b)
		local typeA, typeB = type(a), type(b)
		if typeA == typeB then
			return a < b
		else
			return typeA < typeB
		end
	end

	-- Function to generate diff string
	local function computeDiffString(tableA, tableB)
		local diffString = ""
		for key, value in pairs(tableA) do
			if type(value) == "table" then
				if not tableB[key] or type(tableB[key]) ~= "table" then
					diffString = diffString
						.. "Key "
						.. tostring(key)
						.. " is a table in firstValue, but not in secondValue.\n"
				end
			else
				if tableB[key] ~= value then
					diffString = diffString
						.. "Key "
						.. tostring(key)
						.. ": firstValue is "
						.. tostring(value)
						.. ", secondValue is "
						.. tostring(tableB[key])
						.. "\n"
				end
			end
		end
		return diffString
	end

	-- Check for table type
	if type(firstValue) ~= "table" or type(secondValue) ~= "table" then
		error("Values are not tables")
		return
	end

	-- Sorting and comparing keys
	local function sortAndCompareKeys(tableA, tableB)
		local keysA, keysB = {}, {}
		for key in pairs(tableA) do
			table.insert(keysA, key)
		end
		for key in pairs(tableB) do
			table.insert(keysB, key)
		end
		table.sort(keysA, compare)
		table.sort(keysB, compare)

		if #keysA ~= #keysB then
			return false
		end

		for i = 1, #keysA do
			if keysA[i] ~= keysB[i] then
				return false
			end
		end
		return true
	end

	-- Checking if keys are the same
	if not sortAndCompareKeys(firstValue, secondValue) then
		error("Keys do not match: \n" .. computeDiffString(firstValue, secondValue))
		return
	end

	-- Checking if values are the same
	for key, value in pairs(firstValue) do
		if type(value) == "table" and type(secondValue[key]) == "table" then
			assertions.assertEqualTables(value, secondValue[key])
		elseif value ~= secondValue[key] then
			error(
				"Values do not match for key " .. tostring(key) .. ": \n" .. computeDiffString(firstValue, secondValue)
			)
			return
		end
	end
end

function assertions.assertEqualBooleans(firstValue, secondValue)
	if type(firstValue) ~= "boolean" or type(secondValue) ~= "boolean" then
		return
	end

	if firstValue ~= secondValue then
		error("ASSERTION FAILURE: Expected " .. tostring(secondValue) .. " but got " .. tostring(firstValue), 0)
	end

	return true
end

function assertions.assertEqualPointers(firstValue, secondValue)
	local areBothValuesStructs = type(firstValue) == "cdata" and type(secondValue) == "cdata"
	local areBothValuesUserdata = type(firstValue) == "userdata" and type(secondValue) == "userdata"

	if areBothValuesStructs or areBothValuesUserdata then
		if firstValue == secondValue then
			return true
		else
			error("ASSERTION FAILURE: Expected " .. tostring(secondValue) .. " but got " .. tostring(firstValue), 0)
		end
	else
		error(
			"ASSERTION FAILURE: Both values must be cdata or userdata pointers, but got "
				.. tostring(firstValue)
				.. " and "
				.. tostring(secondValue),
			0
		)
	end
end

function assertions.assertEqualBytes(firstValue, secondValue)
	if type(firstValue) ~= "cdata" or type(secondValue) ~= "cdata" then
		error(
			"ASSERTION FAILURE: Expected two cdata values, got " .. type(firstValue) .. " and " .. type(secondValue),
			0
		)
	end

	local firstLength = ffi.sizeof(firstValue)
	local secondLength = ffi.sizeof(secondValue)

	if ffi_string(firstValue, firstLength) ~= ffi_string(secondValue, secondLength) then
		error(
			"ASSERTION FAILURE: Expected "
				.. tostring(secondValue, secondLength)
				.. " but got "
				.. tostring(firstValue, firstLength),
			0
		)
	end

	return true
end

function assertions.assertEqualFunctions(firstValue, secondValue)
	if type(firstValue) ~= "function" or type(secondValue) ~= "function" then
		error(
			"ASSERTION FAILURE: Expected two function values, got " .. type(firstValue) .. " and " .. type(secondValue),
			0
		)
	end

	if firstValue ~= secondValue then
		error("ASSERTION FAILURE: Expected " .. tostring(secondValue) .. " but got " .. tostring(firstValue), 0)
	end

	return true
end

function assertions.assertEquals(firstValue, secondValue)
	local firstType = type(firstValue)
	local secondType = type(secondValue)

	local areBothValuesBooleans = (firstType == "boolean" and secondType == "boolean")
	local areBothValuesStrings = (firstType == "string" and secondType == "string")
	local areBothValuesNumbers = (firstType == "number" and secondType == "number")
	local areBothValuesUserdata = (firstType == "userdata" and secondType == "userdata")
	local areBothValuesTables = (firstType == "table" and secondType == "table")
	local areBothValuesNil = (firstType == "nil" and secondType == "nil")
	local areBothValuesStructs = (firstType == "cdata" and secondType == "cdata")
	local areBothValuesFunctions = (firstType == "function" and secondType == "function")

	if areBothValuesNil then
		return true
	end -- Short-circuit since there's no point in comparing them (nil is unique)

	if areBothValuesBooleans then
		return assertions.assertEqualBooleans(firstValue, secondValue)
	end

	if areBothValuesStrings then
		return assertions.assertEqualStrings(firstValue, secondValue)
	end

	if areBothValuesNumbers then
		return assertions.assertEqualNumbers(firstValue, secondValue)
	end

	if areBothValuesUserdata then
		return assertions.assertEqualPointers(firstValue, secondValue)
	end

	if areBothValuesTables then
		return assertions.assertEqualTables(firstValue, secondValue)
	end

	if areBothValuesStructs then
		return assertions.assertEqualPointers(firstValue, secondValue)
	end

	if areBothValuesFunctions then
		return assertions.assertEqualFunctions(firstValue, secondValue)
	end

	local errorMessage = format(
		"ASSERTION FAILURE: Expected %s (a %s value) but got %s (a %s value)",
		secondValue,
		secondType,
		firstValue,
		firstType
	)
	error(errorMessage, 0)
end

function assertions.export()
	local functionsToExport = {
		"assertTrue",
		"assertFalse",
		"assertNil",
		"assertThrows",
		"assertDoesNotThrow",
		"assertFailure",
		"assertCallsFunction",
		"assertEqualStrings",
		"assertEqualNumbers",
		"assertEqualTables",
		"assertEqualBooleans",
		"assertEqualPointers",
		"assertEqualBytes",
		"assertEquals",
	}

	for index, functionName in ipairs(functionsToExport) do
		_G[functionName] = assertions[functionName]
	end
end

return assertions
