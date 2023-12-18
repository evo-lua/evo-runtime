local etrace = require("etrace")

describe("etrace", function()
	describe("clear", function()
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
	end)

	describe("list", function()
		after(function()
			etrace.reset()
		end)

		it("should return an empty list of no events have been registered", function()
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

	describe("put", function()
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
end)
