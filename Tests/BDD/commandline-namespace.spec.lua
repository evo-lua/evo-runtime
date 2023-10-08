describe("C_CommandLine", function()
	-- Remove the runtime handlers (they aren't needed after the tests have started running, anyway)
	C_CommandLine.UnregisterAllCommands()

	describe("SetAlias", function()
		after(function()
			C_CommandLine.UnregisterAllCommands()
		end)

		it("should throw if no command was given", function()
			local function setAliasWithNilCommand()
				C_CommandLine.SetAlias(nil, "-t")
			end
			local expectedErrorMessage =
				"Expected argument commandName to be a string value, but received a nil value instead"
			assertThrows(setAliasWithNilCommand, expectedErrorMessage)
		end)

		it("should throw if no shorthand was given", function()
			local function setNilAlias()
				C_CommandLine.SetAlias("invalid", nil)
			end
			local expectedErrorMessage =
				"Expected argument alias to be a string value, but received a nil value instead"
			assertThrows(setNilAlias, expectedErrorMessage)
		end)

		it("should throw if the shorthand was already registered for another command", function()
			-- Since aliases are just commands in disguise, registering them twice doesn't make sense
			C_CommandLine.RegisterCommand("test", function() end, "test")
			C_CommandLine.RegisterCommand("asdf", function() end, "asdf")
			local function registerAliasMoreThanOnce()
				C_CommandLine.SetAlias("test", "-t")
				C_CommandLine.SetAlias("asdf", "-t")
			end
			local expectedErrorMessage = "Cannot set alias -t for command asdf (already used for command test)"
			assertThrows(registerAliasMoreThanOnce, expectedErrorMessage)
		end)

		it("should throw if the command doesn't exist", function()
			local function registerAliasForInvalidCommand()
				C_CommandLine.SetAlias("invalid", "-t")
			end
			local expectedErrorMessage = "Cannot set alias -t for command invalid (no such command was registered)"
			assertThrows(registerAliasForInvalidCommand, expectedErrorMessage)
		end)

		it("should register a shorthand for the given command ", function()
			-- Setup
			local function onHelloCommandExecuted() end
			C_CommandLine.RegisterCommand("hello", onHelloCommandExecuted, "hello")
			local commandsBefore = C_CommandLine.GetCommandList()

			C_CommandLine.SetAlias("hello", "-h")
			local commandsAfter = C_CommandLine.GetCommandList()
			assertEquals(commandsBefore, commandsAfter)

			local function executeCommandViaAlias()
				C_CommandLine.ProcessArguments({ [0] = "-h" })
			end
			assertCallsFunction(executeCommandViaAlias, onHelloCommandExecuted)
		end)
	end)

	describe("RegisterCommand", function()
		it("should throw if a command with the same name has already been registered", function()
			local function registerFooCommand()
				C_CommandLine.RegisterCommand("foo", print)
			end
			assertDoesNotThrow(registerFooCommand)
			assertThrows(
				registerFooCommand,
				"Failed to register command 'foo' (a command handler already exists for this command)"
			)

			-- Cleanup
			C_CommandLine.UnregisterCommand("foo")
		end)

		it("should throw if no command name was given", function()
			local function registerWithoutCommandName()
				C_CommandLine.RegisterCommand(nil, print)
			end
			assertThrows(
				registerWithoutCommandName,
				"Expected argument commandName to be a string value, but received a nil value instead"
			)
		end)

		it("should throw if no command handler was given", function()
			local function registerWithoutCommandHandler()
				C_CommandLine.RegisterCommand("test123", nil)
			end
			assertThrows(
				registerWithoutCommandHandler,
				"Expected argument commandHandler to be a function value, but received a nil value instead"
			)
		end)

		it("should throw if an invalid description was given", function()
			local function registerWithInvalidDescription()
				C_CommandLine.RegisterCommand("test123", print, 42)
			end
			assertThrows(
				registerWithInvalidDescription,
				"Expected argument description to be a string value, but received a number value instead"
			)
		end)

		it("should register the command with a default placeholder description if none was given", function()
			C_CommandLine.RegisterCommand("bar", print)
			assertEquals(C_CommandLine.GetCommandList(), {
				bar = C_CommandLine.PLACEHOLDER_COMMAND_DESCRIPTION,
			})

			-- Cleanup
			C_CommandLine.UnregisterCommand("bar")
		end)

		it("should register the command with the given description if one was given", function()
			local description = "User-defined description (optional argument)"
			C_CommandLine.RegisterCommand("baz", print, description)
			assertEquals(C_CommandLine.GetCommandList(), {
				baz = description,
			})

			-- Cleanup
			C_CommandLine.UnregisterCommand("baz")
		end)
	end)

	describe("UnregisterCommand", function()
		it("should throw if no command name was given", function()
			local function unregisterNilCommand()
				C_CommandLine.UnregisterCommand()
			end

			assertThrows(
				unregisterNilCommand,
				"Expected argument commandName to be a string value, but received a nil value instead"
			)
		end)

		it("should throw if no command with the given name was registered", function()
			local function unregisterInvalidCommand()
				C_CommandLine.UnregisterCommand("invalid")
			end

			assertThrows(unregisterInvalidCommand, "Failed to unregister command 'invalid' (not a registered command)")
		end)

		it("should remove the command handler if an existing command name was given", function()
			C_CommandLine.RegisterCommand("temp", print)
			assertEquals(C_CommandLine.GetCommandList(), {
				temp = C_CommandLine.PLACEHOLDER_COMMAND_DESCRIPTION,
			})
			C_CommandLine.UnregisterCommand("temp")
			assertEquals(C_CommandLine.GetCommandList(), {})
		end)
	end)

	describe("ProcessArguments", function()
		it("should throw if a non-table value was passed", function()
			local invalidValues = {
				42,
				"hi",
				print,
				true,
				false,
				nil,
			}
			for index, value in ipairs(invalidValues) do
				local function processInvalidArguments()
					C_CommandLine.ProcessArguments(value)
				end
				assertThrows(
					processInvalidArguments,
					"Expected argument argumentsVector to be a table value, but received a "
						.. type(value)
						.. " value instead"
				)
			end
		end)

		it("should trigger the registered default handler on invalid command", function()
			-- Setup
			C_CommandLine.SetDefaultHandler(function(command)
				error("This is the default command handler: " .. command, 0)
			end)

			local function triggerDefaultHandler()
				C_CommandLine.ProcessArguments({ [0] = "invalid-command" })
			end
			assertThrows(triggerDefaultHandler, "This is the default command handler: invalid-command")

			-- Cleanup
			C_CommandLine.SetDefaultHandler(C_CommandLine.DispatchCommand)
		end)

		it("should trigger the appropriate command handler if one was registered", function()
			-- Setup
			local function handler(command)
				error("Triggered handler for command " .. command, 0)
			end
			C_CommandLine.RegisterCommand("asdf", handler)

			local function triggerRegisteredHandler()
				C_CommandLine.ProcessArguments({ [0] = "asdf" })
			end
			assertThrows(triggerRegisteredHandler, "Triggered handler for command asdf")

			-- Cleanup
			C_CommandLine.UnregisterCommand("asdf")
		end)
	end)

	describe("GetUsageInfo", function()
		it("should return an empty string if no commands were registered", function()
			assertEquals(C_CommandLine.GetCommandList(), {})
			assertEquals(C_CommandLine.GetUsageInfo(), "")
		end)

		it(
			"should return an ordered list of all registered commands and their description if any were registered",
			function()
				-- Setup
				C_CommandLine.RegisterCommand("foo", print, "Does something else")
				C_CommandLine.RegisterCommand("bar", print, "Does something")

				assertEquals(
					C_CommandLine.GetUsageInfo(),
					"\tbar\t\tDoes something\n" .. "\tfoo\t\tDoes something else\n"
				)

				-- Cleanup
				C_CommandLine.UnregisterCommand("foo")
				C_CommandLine.UnregisterCommand("bar")
			end
		)

		it(
			"should return an ordered list of all registered commands  and their aliases if any were registered",
			function()
				-- Setup
				C_CommandLine.RegisterCommand("foo", print, "Does something else")
				C_CommandLine.RegisterCommand("bar", print, "Does something")
				C_CommandLine.SetAlias("bar", "-b")

				assertEquals(
					C_CommandLine.GetUsageInfo(),
					"\t-b, bar\t\tDoes something\n" .. "\tfoo\t\tDoes something else\n"
				)

				-- Cleanup
				C_CommandLine.UnregisterCommand("foo")
				C_CommandLine.UnregisterCommand("bar")
			end
		)
	end)

	describe("SetDefaultHandler", function()
		it("should throw if a non-function value was passed", function()
			local invalidValues = {
				42,
				"hi",
				{},
				true,
				false,
				nil,
			}
			for index, value in ipairs(invalidValues) do
				local function setInvalidHandler()
					C_CommandLine.SetDefaultHandler(value)
				end
				assertThrows(
					setInvalidHandler,
					"Expected argument newDefaultHandler to be a function value, but received a "
						.. type(value)
						.. " value instead"
				)
			end
		end)
	end)
end)
