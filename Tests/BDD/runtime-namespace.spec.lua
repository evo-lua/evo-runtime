local console = require("console")

describe("C_Runtime", function()
	-- Ideally there should be some high-level snapshot tests, but more plumbing is needed
	-- Not great, but for the time being this will have to do - will revisit later, when it makes sense
	local commandLineAPI = {
		"EvaluateString",
		"PrintVersionString",
		"RunBasicTests",
		"RunDetailedTests",
		"RunMinimalTests",
	}
	for _, exportedFunctionName in ipairs(commandLineAPI) do
		it("should export " .. exportedFunctionName, function()
			assertEquals(type(C_Runtime[exportedFunctionName]), "function")
		end)
	end

	describe("EvaluateString", function()
		it("should evaluate the input as a Lua chunk if given a string value", function()
			local function throwsWhileEvaluating()
				C_Runtime.EvaluateString('error("42", 0)')
			end
			assertThrows(throwsWhileEvaluating, "42")
		end)

		it("should throw if a non-string value was passed", function()
			local function throwsWhileEvaluating()
				C_Runtime.EvaluateString(nil)
			end
			assertThrows(
				throwsWhileEvaluating,
				"Expected argument luaCode to be a string value, but received a nil value instead"
			)
		end)

		it("should return the result of the evaluation", function()
			local returnedValue, anotherReturnedValue = C_Runtime.EvaluateString('return 42, "hello"')
			assertEquals(returnedValue, 42)
			assertEquals(anotherReturnedValue, "hello")
		end)

		it("should print the result of the evaluation to the standard output", function()
			console.capture()
			C_Runtime.EvaluateString('print("meep")')
			local capturedOutput = console.release()
			assertEquals(capturedOutput, "meep\n")
		end)
	end)

	describe("PrintVersionString", function()
		it("should print the build version of the runtime to the standard output", function()
			console.capture()
			C_Runtime.PrintVersionString()
			local capturedOutput = console.release()

			local SEMANTIC_VERSION_STRING_PATTERN = "(v(%d+)%.(%d+)%.(%d+).*)"
			local versionString, expectedMajorVersion, expectedMinorVersion, expectedPatchVersion =
				string.match(EVO_VERSION, SEMANTIC_VERSION_STRING_PATTERN)
			local displayedVersionString, displayedMajorVersion, displayedMinorVersion, displayedPatchVersion =
				string.match(capturedOutput, SEMANTIC_VERSION_STRING_PATTERN)

			assertEquals(displayedVersionString, versionString .. "\n")
			assertEquals(displayedMajorVersion, expectedMajorVersion)
			assertEquals(displayedMinorVersion, expectedMinorVersion)
			assertEquals(displayedPatchVersion, expectedPatchVersion)
		end)
	end)
end)
