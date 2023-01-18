local inspect = require("inspect")

local function testInspectFunction()
	local inspectFunction = inspect.inspect
	assertEquals(type(inspectFunction), "function")

	local someRandomTable = { hi = 42 }
	local result = inspectFunction(someRandomTable)

	local expectedResult = [[
{
  hi = 42
}]]
	assertEquals(result, expectedResult)

	print("OK", "inspect", "inspect")
end

testInspectFunction()

print("OK", "The inspect library should be functional")
