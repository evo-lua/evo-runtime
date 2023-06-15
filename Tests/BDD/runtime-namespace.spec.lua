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

	describe("RunSnapshotTests", function()
		it("should throw if a non-table value was passed", function()
			local function runWithNil()
				C_Runtime.RunSnapshotTests(nil)
			end
			assertThrows(
				runWithNil,
				"Expected argument testCases to be a table value, but received a nil value instead"
			)
		end)

		it("should throw if any of the given test cases is missing a valid programToRun field", function()
			local function runWithInvalidTestCase()
				C_Runtime.RunSnapshotTests({
					["invalid-test-case"] = {
						humanReadableDescription = "This test case is invalid",
						onExit = function() end,
					},
				})
			end
			assertThrows(
				runWithInvalidTestCase,
				"Expected argument programToRun to be a string value, but received a nil value instead"
			)
		end)

		it("should throw if any of the given test cases is missing a valid onExit field", function()
			local function runWithInvalidTestCase()
				C_Runtime.RunSnapshotTests({
					["invalid-test-case"] = {
						humanReadableDescription = "This test case is invalid",
						programToRun = "echo hello world",
					},
				})
			end
			assertThrows(
				runWithInvalidTestCase,
				"Expected argument onExit to be a function value, but received a nil value instead"
			)
		end)

		it("should execute the defined command for each of the given test cases", function()
			local hasExecutedEchoTest, hasExecutedHelloWorldTest
			local testCases = {
				["echo-test"] = {
					humanReadableDescription = "Print some text",
					programToRun = "echo test123",
					onExit = function(observedOutput)
						assertEquals(observedOutput, "test123\n")
						hasExecutedEchoTest = true
					end,
				},
				["hello-world"] = {
					humanReadableDescription = "Print 'hello world'",
					programToRun = "echo hello world",
					onExit = function(observedOutput)
						assertEquals(observedOutput, "hello world\n")
						hasExecutedHelloWorldTest = true
					end,
				},
			}

			C_Runtime.RunSnapshotTests(testCases)
			assertTrue(hasExecutedEchoTest)
			assertTrue(hasExecutedHelloWorldTest)
		end)
	end)
end)
