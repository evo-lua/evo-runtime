local ffi = require("ffi")
local interop = require("interop")

describe("interop", function()
	describe("queue_create", function()
		it("should initialize a cdata handle to an empty event queue", function()
			local queueHandle = interop.bindings.queue_create()
			local initialQueueSize = tonumber(interop.bindings.queue_size(queueHandle))

			assertEquals(type(queueHandle), "cdata")
			assertEquals(initialQueueSize, 0)

			interop.bindings.queue_destroy(queueHandle)
		end)
	end)

	describe("queue_destroy", function()
		it("should have no effect if the given queue handle is invalid", function()
			interop.bindings.queue_destroy(nil) -- No SEGFAULT = success
		end)
	end)

	describe("queue_size", function()
		it("should return 0 if the given queue handle is invalid", function()
			interop.bindings.queue_size(nil) -- No SEGFAULT = success
		end)

		it("should return the number of events in the queue if any have been added", function()
			local queueHandle = interop.bindings.queue_create()

			local event = ffi.new("deferred_event_t")
			interop.bindings.queue_push_event(queueHandle, event)

			local queueSize = tonumber(interop.bindings.queue_size(queueHandle))
			assertEquals(queueSize, 1)

			interop.bindings.queue_destroy(queueHandle)
		end)
	end)

	describe("queue_push_event", function()
		it("should return true if the event type is invalid", function()
			local queueHandle = interop.bindings.queue_create()

			local event = ffi.new("deferred_event_t")
			event.window_focus_details.type = -42 -- Negative = definitely not a supported event type

			local success = interop.bindings.queue_push_event(queueHandle, event)
			interop.bindings.queue_destroy(queueHandle)

			assertTrue(success)
		end)

		it("should return false if the given queue handle is invalid", function()
			local event = ffi.new("deferred_event_t")
			local success = interop.bindings.queue_push_event(nil, event)
			assertFalse(success)
		end)
	end)

	describe("queue_pop_event", function()
		it("should return an error event if the queue is empty", function()
			local queueHandle = interop.bindings.queue_create()

			local event = interop.bindings.queue_pop_event(queueHandle)
			assertEquals(event.error_details.type, ffi.C.ERROR_EVENT)
			assertEquals(event.error_details.code, ffi.C.ERROR_POPPING_EMPTY_QUEUE)

			interop.bindings.queue_destroy(queueHandle)
		end)

		it("should return the next event in the queue if any are available", function()
			local queueHandle = interop.bindings.queue_create()

			local focusEvent = ffi.new("window_focus_event_t")
			focusEvent.type = ffi.C.WINDOW_FOCUS_EVENT
			focusEvent.focused = true

			local firstEvent = ffi.new("deferred_event_t")
			firstEvent.window_focus_details = focusEvent
			interop.bindings.queue_push_event(queueHandle, firstEvent)

			local cursorEvent = ffi.new("cursor_enter_event_t")
			cursorEvent.type = ffi.C.CURSOR_ENTER_EVENT
			cursorEvent.entered = true

			local secondEvent = ffi.new("deferred_event_t")
			secondEvent.cursor_enter_details = cursorEvent
			interop.bindings.queue_push_event(queueHandle, secondEvent)

			local nextEvent = interop.bindings.queue_pop_event(queueHandle)
			assertEquals(nextEvent.window_focus_details.type, firstEvent.window_focus_details.type)

			nextEvent = interop.bindings.queue_pop_event(queueHandle)
			assertEquals(nextEvent.cursor_enter_details.type, secondEvent.cursor_enter_details.type)

			interop.bindings.queue_destroy(queueHandle)
		end)
	end)
end)
