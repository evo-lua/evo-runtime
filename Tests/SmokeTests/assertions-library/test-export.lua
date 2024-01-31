local assertions = require("assertions")

local expectedGlobalAssertions = {
	"assertTrue",
	"assertFalse",
	"assertNil",
	"assertThrows",
	"assertDoesNotThrow",
	"assertFailure",
	"assertCallsFunction",
	"assertEqualStrings",
	"assertEqualNumbers",
	"assertApproximatelyEquals",
	"assertEqualTables",
	"assertEqualBooleans",
	"assertEqualPointers",
	"assertEqualBytes",
	"assertEquals",
}

for index, globalAssertionName in ipairs(expectedGlobalAssertions) do
	local globalAssertionFunction = _G[globalAssertionName]
	assert(
		globalAssertionFunction == nil,
		globalAssertionName .. " should NOT be exported to the global environment before assertions.export was called"
	)
end

assertions.export()

for index, globalAssertionName in ipairs(expectedGlobalAssertions) do
	local globalAssertionFunction = _G[globalAssertionName]
	assert(
		globalAssertionFunction == assertions[globalAssertionName],
		globalAssertionName .. " should be exported to the global environment after assertions.export was called"
	)
end

print("OK", "assertions", "export")
