local etrace = require("etrace")

describe("etrace", function()
	describe("clear", function()
		before(function()
			etrace.reset()
		end)

		after(function()
			etrace.reset()
		end)

		it("should have no effect if no events have been registered", function()
			assertEquals(etrace.filter(), {})
			assertEquals(etrace.list(), {})
			etrace.clear()
			assertEquals(etrace.filter(), {})
			assertEquals(etrace.list(), {})
		end)

		it("should clear the event log without affecting the list of known events", function()
			etrace.register("FOO")
			etrace.enable("FOO")
			etrace.record("FOO")
			etrace.clear()
			assertEquals(etrace.filter(), {})
			assertEquals(etrace.list(), {
				FOO = true,
			})
		end)
	end)

	describe("reset", function()
		it("should have no effect if no events have been registered", function()
			assertEquals(etrace.filter(), {})
			assertEquals(etrace.list(), {})
			etrace.reset()
			assertEquals(etrace.filter(), {})
			assertEquals(etrace.list(), {})
		end)

		it("should clear the event log as well as the list of known events", function()
			etrace.register("TEST_EVENT")
			etrace.enable("TEST_EVENT")
			etrace.record("TEST_EVENT")
			etrace.reset()
			assertEquals(etrace.filter(), {})
			assertEquals(etrace.list(), {})
		end)

		it("should reset the list of subscribers", function()
			etrace.register("TEST_EVENT")
			etrace.subscribe("TEST_EVENT", print)
			assertEquals(etrace.subscribers.TEST_EVENT, { [print] = print })
			etrace.reset()
			assertEquals(etrace.subscribers.TEST_EVENT, nil)
		end)
	end)

	describe("list", function()
		after(function()
			etrace.reset()
		end)

		it("should return an empty list if no events have been registered", function()
			assertEquals(etrace.list(), {})
		end)

		it("should return a list of all known events if any have been registered", function()
			etrace.register("TEST_EVENT_A")
			etrace.register("TEST_EVENT_B")
			etrace.register("TEST_EVENT_C")
			assertEquals(etrace.list(), {
				TEST_EVENT_A = false,
				TEST_EVENT_B = false,
				TEST_EVENT_C = false,
			})
		end)

		it("should return the status of all known events if any have been registered", function()
			etrace.register("TEST_EVENT_F")
			etrace.register("TEST_EVENT_G")
			etrace.enable("TEST_EVENT_G")
			etrace.register("TEST_EVENT_H")
			assertEquals(etrace.list(), {
				TEST_EVENT_F = false,
				TEST_EVENT_G = true,
				TEST_EVENT_H = false,
			})
		end)
	end)

	describe("register", function()
		after(function()
			etrace.reset()
		end)

		it("should throw if attempting to register an event that's already known", function()
			assertThrows(function()
				etrace.register("SOME_EVENT")
				etrace.register("ANOTHER_EVENT")
				etrace.register("SOME_EVENT")
			end, "Known event SOME_EVENT cannot be registered again")
		end)

		it("should add the event to the list of known events and disable it", function()
			etrace.register("DISABLED_EVENT_ABC")
			assertFalse(etrace.status("DISABLED_EVENT_ABC"))
			assertEquals(etrace.list(), {
				DISABLED_EVENT_ABC = false,
			})
		end)

		it("should add all events to the list of known events and disable them", function()
			etrace.register({
				"DISABLED_EVENT_ABC",
				"DISABLED_EVENT_DEF",
			})
			assertFalse(etrace.status("DISABLED_EVENT_ABC"))
			assertFalse(etrace.status("DISABLED_EVENT_DEF"))
			assertEquals(etrace.list(), {
				DISABLED_EVENT_ABC = false,
				DISABLED_EVENT_DEF = false,
			})
		end)

		it("should throw if no event name was passed", function()
			assertThrows(function()
				etrace.register()
			end, "Invalid event nil cannot be registered")
		end)
	end)

	describe("unregister", function()
		after(function()
			etrace.reset()
		end)

		it("should throw if attempting to unregister an unknown event", function()
			assertThrows(function()
				etrace.unregister("SOME_EVENT")
			end, "Unknown event SOME_EVENT cannot be unregistered")
		end)

		it("should throw if attempting to unregister at least one matching unknown event ", function()
			assertThrows(function()
				etrace.register("KNOWN_EVENT")
				etrace.unregister({
					"KNOWN_EVENT",
					"UNKNOWN_EVENT",
				})
			end, "Unknown event UNKNOWN_EVENT cannot be unregistered")
		end)

		it("should remove all known events if no specific event names were passed", function()
			etrace.register("EVENT_A")
			etrace.register("EVENT_B")
			etrace.register("EVENT_C")
			etrace.unregister()
			assertEquals(etrace.list(), {})
		end)

		it("should remove all known events if an empty list of event names were passed", function()
			etrace.register("EVENT_A")
			etrace.register("EVENT_B")
			etrace.register("EVENT_C")
			etrace.unregister({})
			assertEquals(etrace.list(), {})
		end)

		it("should remove all matching known events if a list of event names was passed", function()
			etrace.register("EVENT_A")
			etrace.register("EVENT_B")
			etrace.register("EVENT_C")
			etrace.unregister({
				"EVENT_A",
				"EVENT_C",
			})
			assertEquals(etrace.list(), {
				EVENT_B = false,
			})
		end)
	end)

	describe("enable", function()
		after(function()
			etrace.reset()
		end)

		it("should throw if attempting to enable an unknown event", function()
			assertThrows(function()
				etrace.enable("UNKNOWN_EVENT_A")
			end, "Cannot enable unknown event UNKNOWN_EVENT_A")
		end)

		it("should enable the event if passed a known event name", function()
			etrace.register("KNOWN_EVENT_A")
			assertFalse(etrace.status("KNOWN_EVENT_A"))
			etrace.enable("KNOWN_EVENT_A")
			assertTrue(etrace.status("KNOWN_EVENT_A"))
			etrace.disable("KNOWN_EVENT_A")
			assertFalse(etrace.status("KNOWN_EVENT_A"))
		end)

		it("should enable all events if passed a list of known event names", function()
			etrace.register("KNOWN_EVENT_A")
			etrace.register("KNOWN_EVENT_B")
			assertFalse(etrace.status("KNOWN_EVENT_A"))
			assertFalse(etrace.status("KNOWN_EVENT_B"))
			etrace.enable({
				"KNOWN_EVENT_A",
				"KNOWN_EVENT_B",
			})
			assertTrue(etrace.status("KNOWN_EVENT_A"))
			assertTrue(etrace.status("KNOWN_EVENT_B"))
		end)

		it("should throw if attempting to enable at least one unknown event", function()
			assertThrows(function()
				etrace.register("KNOWN_EVENT")
				etrace.enable({
					"KNOWN_EVENT",
					"UNKNOWN_EVENT",
				})
			end, "Cannot enable unknown event UNKNOWN_EVENT")
		end)

		it("should enable all events if no argument was passed", function()
			etrace.register("KNOWN_EVENT_A")
			etrace.register("KNOWN_EVENT_B")
			assertFalse(etrace.status("KNOWN_EVENT_B"))
			assertFalse(etrace.status("KNOWN_EVENT_A"))
			etrace.enable()
			assertTrue(etrace.status("KNOWN_EVENT_B"))
			assertTrue(etrace.status("KNOWN_EVENT_A"))
		end)
	end)

	describe("disable", function()
		after(function()
			etrace.reset()
		end)

		it("should throw if attempting to disable an unknown event", function()
			assertThrows(function()
				etrace.disable("UNKNOWN_EVENT_B")
			end, "Cannot disable unknown event UNKNOWN_EVENT_B")
		end)

		it("should disable the event if passed a known event name", function()
			etrace.register("KNOWN_EVENT_B")
			etrace.disable("KNOWN_EVENT_B")
			assertFalse(etrace.status("KNOWN_EVENT_B"))
		end)

		it("should disable the event if passed a known event name", function()
			etrace.register("KNOWN_EVENT_A")
			assertFalse(etrace.status("KNOWN_EVENT_A"))
			etrace.enable("KNOWN_EVENT_A")
			assertTrue(etrace.status("KNOWN_EVENT_A"))
			etrace.disable("KNOWN_EVENT_A")
			assertFalse(etrace.status("KNOWN_EVENT_A"))
		end)

		it("should disable all events if passed a list of known event names", function()
			etrace.register("KNOWN_EVENT_A")
			etrace.register("KNOWN_EVENT_B")
			etrace.enable("KNOWN_EVENT_A")
			etrace.enable("KNOWN_EVENT_B")
			assertTrue(etrace.status("KNOWN_EVENT_B"))
			assertTrue(etrace.status("KNOWN_EVENT_A"))

			etrace.disable({
				"KNOWN_EVENT_A",
				"KNOWN_EVENT_B",
			})
			assertFalse(etrace.status("KNOWN_EVENT_A"))
			assertFalse(etrace.status("KNOWN_EVENT_B"))
		end)

		it("should disable all events if no argument was passed", function()
			etrace.register("KNOWN_EVENT_A")
			etrace.register("KNOWN_EVENT_B")
			assertFalse(etrace.status("KNOWN_EVENT_A"))
			assertFalse(etrace.status("KNOWN_EVENT_B"))
			etrace.enable()
			assertTrue(etrace.status("KNOWN_EVENT_A"))
			assertTrue(etrace.status("KNOWN_EVENT_B"))
			etrace.disable()
			assertFalse(etrace.status("KNOWN_EVENT_A"))
			assertFalse(etrace.status("KNOWN_EVENT_B"))
		end)
	end)

	describe("status", function()
		after(function()
			etrace.reset()
		end)

		it("should return true if passed a known event that's currently enabled", function()
			etrace.register("ENABLED_EVENT")
			etrace.enable("ENABLED_EVENT")
			assertTrue(etrace.status("ENABLED_EVENT"))
		end)

		it("should return false if passed a known event that's currently disabled", function()
			etrace.register("DISABLED_EVENT")
			etrace.disable("DISABLED_EVENT")
			assertEquals(etrace.status("DOES_NOT_EXIST"), nil)
		end)

		it("should return nil if the passed event is unknown", function()
			assertEquals(etrace.status("DOES_NOT_EXIST"), nil)
		end)
	end)

	describe("record", function()
		after(function()
			etrace.reset()
		end)

		it("should throw if passed an unknown event", function()
			assertThrows(function()
				etrace.record("DOES_NOT_EXIST")
			end, "Cannot record unknown event DOES_NOT_EXIST")
		end)

		it("should have no effect if passed a known but disabled event", function()
			etrace.register("DISABLED_EVENT")
			etrace.disable("DISABLED_EVENT")
			etrace.record("DISABLED_EVENT")
			etrace.record("DISABLED_EVENT")
			etrace.record("DISABLED_EVENT")
			assertEquals(etrace.filter(), {})
		end)

		it("should store the event payload if the event is currently enabled", function()
			etrace.register("EVENT_WITH_PAYLOAD")
			etrace.register("EVENT_WITHOUT_PAYLOAD")
			etrace.enable("EVENT_WITH_PAYLOAD")
			etrace.enable("EVENT_WITHOUT_PAYLOAD")
			etrace.record("EVENT_WITH_PAYLOAD", { 42 })
			etrace.record("EVENT_WITHOUT_PAYLOAD", nil)
			etrace.record("EVENT_WITH_PAYLOAD", { hi = 123 })
			etrace.record("EVENT_WITH_PAYLOAD", { print })
			etrace.record("EVENT_WITHOUT_PAYLOAD")

			local expectedEventLog = {
				{ name = "EVENT_WITH_PAYLOAD", payload = { 42 } },
				{ name = "EVENT_WITHOUT_PAYLOAD", payload = { nil } },
				{ name = "EVENT_WITH_PAYLOAD", payload = { hi = 123 } },
				{ name = "EVENT_WITH_PAYLOAD", payload = { print } },
				{ name = "EVENT_WITHOUT_PAYLOAD", payload = {} },
			}

			local eventLog = etrace.filter()
			assertEquals(#eventLog, #expectedEventLog)
			assertEquals(eventLog[1], expectedEventLog[1])
			assertEquals(eventLog[2], expectedEventLog[2])
			assertEquals(eventLog[3], expectedEventLog[3])
			assertEquals(eventLog[4], expectedEventLog[4])
			assertEquals(eventLog[5], expectedEventLog[5])
		end)
	end)

	describe("filter", function()
		after(function()
			etrace.reset()
		end)

		it("should return the complete event log if no event name was passed ", function()
			etrace.register("EVENT_WITH_PAYLOAD")
			etrace.register("EVENT_WITHOUT_PAYLOAD")
			etrace.register("SOME_EVENT")
			etrace.enable("EVENT_WITH_PAYLOAD")
			etrace.enable("EVENT_WITHOUT_PAYLOAD")
			etrace.enable("SOME_EVENT")
			etrace.record("EVENT_WITH_PAYLOAD", { 42 })
			etrace.record("EVENT_WITHOUT_PAYLOAD")
			etrace.record("SOME_EVENT")

			local expectedEventLog = {
				{ name = "EVENT_WITH_PAYLOAD", payload = { 42 } },
				{ name = "EVENT_WITHOUT_PAYLOAD", payload = {} },
				{ name = "SOME_EVENT", payload = {} },
			}

			local eventLog = etrace.filter()
			assertEquals(#eventLog, #expectedEventLog)
			assertEquals(eventLog[1], expectedEventLog[1])
			assertEquals(eventLog[2], expectedEventLog[2])
			assertEquals(eventLog[3], expectedEventLog[3])
		end)

		it("should return the complete event log if an empty list of event names was passed ", function()
			etrace.register("EVENT_WITH_PAYLOAD")
			etrace.register("EVENT_WITHOUT_PAYLOAD")
			etrace.register("SOME_EVENT")
			etrace.enable("EVENT_WITH_PAYLOAD")
			etrace.enable("EVENT_WITHOUT_PAYLOAD")
			etrace.enable("SOME_EVENT")
			etrace.record("EVENT_WITH_PAYLOAD", { 42 })
			etrace.record("EVENT_WITHOUT_PAYLOAD")
			etrace.record("SOME_EVENT")

			local expectedEventLog = {
				{ name = "EVENT_WITH_PAYLOAD", payload = { 42 } },
				{ name = "EVENT_WITHOUT_PAYLOAD", payload = {} },
				{ name = "SOME_EVENT", payload = {} },
			}

			local eventLog = etrace.filter({})
			assertEquals(#eventLog, #expectedEventLog)
			assertEquals(eventLog[1], expectedEventLog[1])
			assertEquals(eventLog[2], expectedEventLog[2])
			assertEquals(eventLog[3], expectedEventLog[3])
		end)

		it("should throw if an unknown event was passed", function()
			assertThrows(function()
				etrace.filter("UNKNOWN_EVENT")
			end, "Cannot filter event log for unknown event UNKNOWN_EVENT")
		end)

		it("should return a filtered event log if a known event was passed", function()
			etrace.register("EVENT_WITH_PAYLOAD")
			etrace.register("EVENT_WITHOUT_PAYLOAD")
			etrace.enable("EVENT_WITH_PAYLOAD")
			etrace.enable("EVENT_WITHOUT_PAYLOAD")
			etrace.record("EVENT_WITH_PAYLOAD", 42)
			etrace.record("EVENT_WITHOUT_PAYLOAD", nil)
			etrace.record("EVENT_WITH_PAYLOAD", { hi = 123 })
			etrace.record("EVENT_WITH_PAYLOAD", print)
			etrace.record("EVENT_WITHOUT_PAYLOAD")

			local expectedEventLog = {
				{ name = "EVENT_WITHOUT_PAYLOAD", payload = { nil } },
				{ name = "EVENT_WITHOUT_PAYLOAD", payload = {} },
			}

			local eventLog = etrace.filter("EVENT_WITHOUT_PAYLOAD")
			assertEquals(#eventLog, #expectedEventLog)
			assertEquals(eventLog[1], expectedEventLog[1])
			assertEquals(eventLog[2], expectedEventLog[2])
		end)

		it("should throw if a list containing at least one unknown event was passed", function()
			etrace.register("KNOWN_EVENT")

			assertThrows(function()
				etrace.filter({
					"KNOWN_EVENT",
					"UNKNOWN_EVENT",
				})
			end, "Cannot filter event log for unknown event UNKNOWN_EVENT")
		end)

		it("should return a filtered event log if a list of known events was passed", function()
			etrace.register("EVENT_WITH_PAYLOAD")
			etrace.register("EVENT_WITHOUT_PAYLOAD")
			etrace.register("SOME_EVENT")
			etrace.enable("EVENT_WITH_PAYLOAD")
			etrace.enable("EVENT_WITHOUT_PAYLOAD")
			etrace.enable("SOME_EVENT")
			etrace.record("EVENT_WITH_PAYLOAD", 42)
			etrace.record("EVENT_WITHOUT_PAYLOAD", nil)
			etrace.record("EVENT_WITH_PAYLOAD", { hi = 123 })
			etrace.record("EVENT_WITH_PAYLOAD", print)
			etrace.record("EVENT_WITHOUT_PAYLOAD")
			etrace.record("SOME_EVENT")

			local expectedEventLog = {
				{ name = "EVENT_WITHOUT_PAYLOAD", payload = { nil } },
				{ name = "EVENT_WITHOUT_PAYLOAD", payload = {} },
				{ name = "SOME_EVENT", payload = {} },
			}

			local eventLog = etrace.filter({
				"EVENT_WITHOUT_PAYLOAD",
				"SOME_EVENT",
			})
			assertEquals(#eventLog, #expectedEventLog)
			assertEquals(eventLog[1], expectedEventLog[1])
			assertEquals(eventLog[2], expectedEventLog[2])
			assertEquals(eventLog[3], expectedEventLog[3])
		end)

		it("should return a copy of the list and not a reference that can change after the fact", function()
			etrace.register("SOME_EVENT")
			etrace.register("ANOTHER_EVENT")
			etrace.enable("SOME_EVENT")
			etrace.enable("ANOTHER_EVENT")

			etrace.record("SOME_EVENT")
			local eventLog = etrace.filter()
			local expectedEventLog = {
				{ name = "SOME_EVENT", payload = {} },
			}

			-- So far, so good...
			assertEquals(#eventLog, #expectedEventLog)
			assertEquals(eventLog[1], expectedEventLog[1])

			etrace.record("ANOTHER_EVENT")

			-- If a copy of the internal event log is returned, more events can be added after the fact
			assertEquals(#eventLog, #expectedEventLog)
			assertEquals(eventLog[1], expectedEventLog[1])
		end)
	end)

	describe("subscribe", function()
		before(function()
			etrace.reset()
		end)

		it("should throw if a non-string event name was passed", function()
			assertThrows(function()
				etrace.subscribe(42, print)
			end, "Expected argument event to be a string value, but received a number value instead")
		end)

		it("should throw if an unsupported event listener type was passed", function()
			etrace.register("SOME_EVENT")
			assertThrows(function()
				etrace.subscribe("SOME_EVENT", 42)
			end, "Invalid listener 42 of type number cannot subscribe to event SOME_EVENT")
		end)

		it("should throw if the provided function listener is already registered for the given event", function()
			local function listener(self, event, payload) end
			etrace.register("SOME_EVENT")
			etrace.subscribe("SOME_EVENT", listener)
			assertThrows(function()
				etrace.subscribe("SOME_EVENT", listener)
			end, format("Listener %s of type function is already subscribed to event SOME_EVENT", tostring(listener)))
		end)

		it("should throw if the provided table listener is already registered for the given event", function()
			local listener = {
				SOME_EVENT = function(self, event, payload) end,
			}
			etrace.register("SOME_EVENT")
			etrace.subscribe("SOME_EVENT", listener)
			assertThrows(function()
				etrace.subscribe("SOME_EVENT", listener)
			end, format("Listener %s of type table is already subscribed to event SOME_EVENT", tostring(listener)))
		end)

		it("should throw if the provided event name is not registered", function()
			assertThrows(function()
				etrace.subscribe("HELLO_WORLD", print)
			end, format(
				"Cannot subscribe listener %s of type function to unknown event HELLO_WORLD",
				tostring(print)
			))
		end)

		it("should throw if the provided table listener does not have an event handler for the given event", function()
			local listener = {}
			etrace.register("SOME_EVENT")
			assertThrows(
				function()
					etrace.subscribe("SOME_EVENT", listener)
				end,
				format(
					"Listener %s of type table is missing a default handler for event SOME_EVENT",
					tostring(listener)
				)
			)
		end)

		it("should add the provided function listener to the list of subscribers for the given event", function()
			etrace.register("SOME_EVENT")
			etrace.subscribe("SOME_EVENT", print)
			assertEquals(etrace.subscribers.SOME_EVENT[print], print)
		end)

		it("should add the provided table listener to the list of subscribers for the given event", function()
			local listener = { SOME_EVENT = print }
			etrace.register("SOME_EVENT")
			etrace.subscribe("SOME_EVENT", listener)
			assertEquals(etrace.subscribers.SOME_EVENT[listener], print)
		end)
	end)

	describe("unsubscribe", function()
		before(function()
			etrace.reset()
		end)

		it("should throw if a non-string event name was passed", function()
			assertThrows(function()
				etrace.unsubscribe(42, print)
			end, "Expected argument event to be a string value, but received a number value instead")
		end)

		it("should throw if an unsupported event listener type was passed", function()
			etrace.register("SOME_EVENT")
			assertThrows(function()
				etrace.unsubscribe("SOME_EVENT", 42)
			end, "Invalid listener 42 of type number cannot unsubscribe from event SOME_EVENT")
		end)

		it("should throw if the provided function listener is not registered for the given event", function()
			local function listener(self, event, payload) end
			etrace.register("SOME_EVENT")
			assertThrows(function()
				etrace.unsubscribe("SOME_EVENT", listener)
			end, format("Listener %s of type function is not subscribed to event SOME_EVENT", tostring(listener)))
		end)

		it("should throw if the provided table listener is not registered for the given event", function()
			local listener = {
				SOME_EVENT = function(self, event, payload) end,
			}
			etrace.register("SOME_EVENT")
			assertThrows(function()
				etrace.unsubscribe("SOME_EVENT", listener)
			end, format("Listener %s of type table is not subscribed to event SOME_EVENT", tostring(listener)))
		end)

		it("should throw if the provided event name is not registered", function()
			assertThrows(
				function()
					etrace.unsubscribe("HELLO_WORLD", print)
				end,
				format(
					"Cannot unsubscribe listener %s of type function from unknown event HELLO_WORLD",
					tostring(print)
				)
			)
		end)

		it("should remove the provided function listener from the list of subscribers for the given event", function()
			etrace.register("SOME_EVENT")
			etrace.subscribe("SOME_EVENT", print)
			assertEquals(etrace.subscribers.SOME_EVENT[print], print)
			etrace.unsubscribe("SOME_EVENT", print)
			assertEquals(etrace.subscribers.SOME_EVENT, {})
		end)

		it("should remove the provided table listener from the list of subscribers for the given event", function()
			local listener = { SOME_EVENT = print }
			etrace.register("SOME_EVENT")
			etrace.subscribe("SOME_EVENT", listener)
			assertEquals(etrace.subscribers.SOME_EVENT[listener], print)
			etrace.unsubscribe("SOME_EVENT", listener)
			assertEquals(etrace.subscribers.SOME_EVENT, {})
		end)
	end)

	describe("notify", function()
		before(function()
			etrace.reset()
		end)

		it("should throw if a non-string event name was passed", function()
			assertThrows(function()
				etrace.notify(42)
			end, "Expected argument event to be a string value, but received a number value instead")
		end)

		it("should throw if a non-table payload was passed", function()
			etrace.register("SOME_EVENT")
			assertThrows(function()
				etrace.notify("SOME_EVENT", 42)
			end, "Expected argument payload to be a table value, but received a number value instead")
		end)

		it("should call all subscribed listeners with the event name and payload", function()
			local notifiedListeners = {}
			local providedArguments = {}

			local tableListener = {
				MEEP = function(self, event, payload)
					-- Should pass self to enable use of the : syntax
					notifiedListeners[self] = true
					providedArguments.tableListener = { self, event, payload }
				end,
			}
			local function functionListener(event, payload)
				-- Should not pass self since that seems rather useless
				notifiedListeners[functionListener] = true
				providedArguments.functionListener = { event, payload }
			end

			etrace.register("MEEP")
			etrace.enable("MEEP")
			etrace.subscribe("MEEP", tableListener)
			etrace.subscribe("MEEP", functionListener)
			etrace.notify("MEEP", { hello = 42 })
			assertTrue(notifiedListeners[tableListener])
			assertTrue(notifiedListeners[functionListener])
			assertEquals(providedArguments.tableListener, { tableListener, "MEEP", { hello = 42 } })
			assertEquals(providedArguments.functionListener, { "MEEP", { hello = 42 } })
		end)

		it("should handle gracefully the case where there are no subscribers for a given event", function()
			etrace.register("MEEP")
			etrace.notify("MEEP", { hello = 42 }) -- Should not error
		end)

		it("should pass an empty payload table if none was provided", function()
			local providedArguments = {}

			local function functionListener(event, payload)
				providedArguments.functionListener = { event, payload }
			end

			etrace.register("MEEP")
			etrace.enable("MEEP")
			etrace.subscribe("MEEP", functionListener)
			etrace.notify("MEEP")
			assertEquals(providedArguments.functionListener, { "MEEP", {} })
		end)

		it("should still work if logging for the given event is disabled", function()
			local providedArguments = {}

			local function functionListener(event, payload)
				providedArguments.functionListener = { event, payload }
			end

			etrace.register("MEEP")
			etrace.disable("MEEP")
			etrace.subscribe("MEEP", functionListener)
			etrace.notify("MEEP", { hello = 42 })
			assertEquals(providedArguments.functionListener[1], "MEEP")
			assertEquals(providedArguments.functionListener[2].hello, 42)
		end)
	end)

	describe("publish", function()
		before(function()
			etrace.reset()
		end)

		it("should throw if a non-string event name was passed", function()
			assertThrows(function()
				etrace.publish(42)
			end, "Expected argument event to be a string value, but received a number value instead")
		end)

		it("should throw if a non-table payload was passed", function()
			etrace.register("SOME_EVENT")
			assertThrows(function()
				etrace.publish("SOME_EVENT", 42)
			end, "Expected argument payload to be a table value, but received a number value instead")
		end)

		it("should record the event with the provided payload", function()
			local function functionListener(event, payload) end

			etrace.register("MEEP")
			etrace.enable("MEEP")
			etrace.subscribe("MEEP", functionListener)
			etrace.publish("MEEP", { hello = 42 })

			assertEquals(etrace.filter(), {
				{
					name = "MEEP",
					payload = { hello = 42 },
				},
			})
		end)

		it("should notify subscribers of the event and pass on the provided payload", function()
			local providedArguments = {}

			local function functionListener(event, payload)
				providedArguments.functionListener = { event, payload }
			end

			etrace.register("MEEP")
			etrace.enable("MEEP")
			etrace.subscribe("MEEP", functionListener)
			etrace.publish("MEEP", { hello = 42 })
			assertEquals(providedArguments.functionListener, { "MEEP", { hello = 42 } })
		end)

		it("should still work if logging for the given event is disabled", function()
			local providedArguments = {}

			local function functionListener(event, payload)
				providedArguments.functionListener = { event, payload }
			end

			etrace.register("MEEP")
			etrace.subscribe("MEEP", functionListener)
			etrace.publish("MEEP", { hello = 42 })
			-- Disabling event notifications would break any listener relying on the event system
			assertEquals(providedArguments.functionListener[1], "MEEP")
			assertEquals(providedArguments.functionListener[2].hello, 42)

			-- The log should be empty, however as logging was indeed disabled
			assertEquals(etrace.filter(), {})
		end)
	end)
end)
