-- If there's an issue with the native bootstrapping code that initializes the Lua environment, all bets are off
local transform = require("transform")

print()
print("Running basic smoke tests ...")
print()

local assertions = {
	{
		actual = arg[0],
		expected = "Tests/smoke-test.lua",
		description = "The global arg table should contain the script name at index 0",
	},
	{
		actual = type(transform),
		expected = "table",
		description = "The transform library should be preloaded",
	},
}

for _, assertionInfo in ipairs(assertions) do
	assert(assertionInfo.actual == assertionInfo.expected, assertionInfo.description)
	print("OK", assertionInfo.description)
end

print()
print("Good news, everyone! There's at least a chance that the runtime isn't completely broken - time to celebrate:")
print()
print("(>'-')> <('-'<) ^('-')^ v('-')v(>'-')> (^-^)")
