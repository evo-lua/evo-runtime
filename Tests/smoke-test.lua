local assertions = require("assertions")
local transform = require("transform")
local uv = require("uv")
local validation = require("validation")

print()
print("Running basic smoke tests ...")
print()

local testCases = {
	{
		actual = arg[0],
		expected = "Tests/smoke-test.lua",
		description = "The global arg table should contain the script name at index 0",
	},
	{
		actual = type(assertions),
		expected = "table",
		description = "The assertions library should be preloaded",
	},
	{
		actual = type(transform),
		expected = "table",
		description = "The transform library should be preloaded",
	},
	{
		actual = type(uv),
		expected = "table",
		description = "The uv library should be preloaded",
	},
	{
		actual = type(validation),
		expected = "table",
		description = "The validation library should be preloaded",
	},
}

for _, assertionInfo in ipairs(testCases) do
	assert(assertionInfo.actual == assertionInfo.expected, assertionInfo.description)
	print("OK", assertionInfo.description)
end

-- Since there's no import library available at this stage, let's just assume this script always runs from the project root
dofile("Tests/SmokeTests/test-assertions-library.lua")
dofile("Tests/SmokeTests/test-validation-library.lua")

print()
print("Good news, everyone! There's at least a chance that the runtime isn't completely broken - time to celebrate:")
print()
print("(>'-')> <('-'<) ^('-')^ v('-')v(>'-')> (^-^)")
