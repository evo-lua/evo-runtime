local bdd = require("bdd")
local it = bdd.it

local function testNoLabelCase()
	local function runWithNilLabel()
		it(nil, function() end)
	end
	local expectedErrorMessage = "Expected argument label to be a string value, but received a nil value instead"
	assertThrows(runWithNilLabel, expectedErrorMessage)
end

local function testNoFunctionCase()
	local function runWithNilTestFunction()
		it("something", nil)
	end
	local expectedErrorMessage =
		"Expected argument testFunction to be a function value, but received a nil value instead"
	assertThrows(runWithNilTestFunction, expectedErrorMessage)
end

local function testDescribe()
	testNoLabelCase()
	testNoFunctionCase()
end

testDescribe()

print("OK", "bdd", "it")
