local dump = debug.dump

local dumpOptions = {
	indent = "\t",
	silent = true,
}

local function testDebugDump()
	assertEquals(type(dump), "function")

	local someTable = { hello = "world" }
	local dumpValue = dump(someTable, dumpOptions)

	local expectedDumpValue = [[
{
	hello = "world"
}]]
	assertEquals(dumpValue, expectedDumpValue)
end

testDebugDump()

print("OK", "debug", "dump")
