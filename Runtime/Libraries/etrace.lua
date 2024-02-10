local json = require("json")
local transform = require("transform")
local validation = require("validation")
local validateString = validation.validateString
local validateTable = validation.validateTable

local ipairs = ipairs
local error = error
local pairs = pairs
local tostring = tostring
local type = type

local format = string.format
local table_insert = table.insert

local etrace = {
	registeredEvents = {},
	eventLog = {},
	subscribers = {},
	isForceEnabled = false,
}

function etrace.reset()
	etrace.registeredEvents = {}
	etrace.eventLog = {}
	etrace.subscribers = {}
end

function etrace.clear()
	etrace.eventLog = {}
end

function etrace.list()
	return etrace.registeredEvents
end

function etrace.register(event)
	if type(event) == "table" then
		for key, value in ipairs(event) do
			etrace.register(value)
		end

		return
	end

	if event == nil then
		event = tostring(nil)
		error(format("Invalid event %s cannot be registered", event), 0)
	end

	if etrace.registeredEvents[event] ~= nil then
		error(format("Known event %s cannot be registered again", event), 0)
	end

	etrace.registeredEvents[event] = false
end

function etrace.unregister(event)
	if type(event) == "table" then
		if #event == 0 then
			for key, value in pairs(etrace.registeredEvents) do
				etrace.registeredEvents[key] = nil
			end
		end

		for key, value in ipairs(event) do
			etrace.unregister(value)
		end

		return
	end

	if event == nil then
		for key, value in pairs(etrace.registeredEvents) do
			etrace.registeredEvents[key] = nil
		end

		return
	end

	if etrace.registeredEvents[event] == nil then
		error(format("Unknown event %s cannot be unregistered", event), 0)
	end

	etrace.registeredEvents[event] = nil
end

function etrace.enable(event)
	if event == nil then
		for name, enabledFlag in pairs(etrace.registeredEvents) do
			etrace.registeredEvents[name] = true
		end

		return
	end

	if type(event) == "table" then
		for key, value in ipairs(event) do
			etrace.enable(value)
		end

		return
	end

	if etrace.registeredEvents[event] == nil then
		error(format("Cannot enable unknown event %s", event), 0)
	end

	etrace.registeredEvents[event] = true
end

function etrace.disable(event)
	if event == nil then
		for name, enabledFlag in pairs(etrace.registeredEvents) do
			etrace.registeredEvents[name] = false
		end

		return
	end

	if type(event) == "table" then
		for key, value in ipairs(event) do
			etrace.disable(value)
		end

		return
	end

	if etrace.registeredEvents[event] == nil then
		error(format("Cannot disable unknown event %s", event), 0)
	end

	etrace.registeredEvents[event] = false
end

function etrace.status(event)
	return etrace.registeredEvents[event]
end

function etrace.record(event, payload)
	payload = payload or {}

	if etrace.registeredEvents[event] == nil then
		error(format("Cannot record unknown event %s", event), 0)
	end

	if etrace.registeredEvents[event] == false and not etrace.isForceEnabled then
		return
	end

	local entry = {
		name = event,
		payload = payload,
	}
	table_insert(etrace.eventLog, entry)

	if etrace.isForceEnabled then
		print(etrace.stringify(event, payload))
	end
end

function etrace.stringify(event, payload)
	local payloadString = json.stringify(payload, { sort_keys = true })
	return format(transform.brightBlue("[EVENT] %s\t%s"), event, payloadString)
end

function etrace.filter(event)
	if event == nil or (type(event) == "table" and #event == 0) then
		-- This may be modified if other events are created
		return table.copy(etrace.eventLog)
	end

	local events = {}
	local filteredEventLog = {}
	if type(event) == "string" then
		events = { [event] = true }
	elseif type(event) == "table" then
		for index, name in ipairs(event) do
			-- Leave the array part intact since it's later discarded anyway
			events[name] = true
		end
	end

	for name, _ in pairs(events) do
		if name ~= nil and etrace.registeredEvents[name] == nil then
			error(format("Cannot filter event log for unknown event %s", name), 0)
		end
	end

	for index, entry in pairs(etrace.eventLog) do
		if events[entry.name] == true then
			table_insert(filteredEventLog, entry)
		end
	end

	return filteredEventLog
end

function etrace.subscribe(event, listener)
	validateString(event, "event")

	if etrace.registeredEvents[event] == nil then
		error(
			format(
				"Cannot subscribe listener %s of type %s to unknown event %s",
				tostring(listener),
				type(listener),
				event
			),
			0
		)
	end

	etrace.subscribers[event] = etrace.subscribers[event] or {}
	if etrace.subscribers[event][listener] ~= nil then
		error(
			format(
				"Listener %s of type %s is already subscribed to event %s",
				tostring(listener),
				type(listener),
				event
			),
			0
		)
	end

	if type(listener) == "function" then
		etrace.subscribers[event][listener] = listener
	elseif type(listener) == "table" then
		if type(listener[event]) ~= "function" then
			error(
				format(
					"Listener %s of type %s is missing a default handler for event %s",
					tostring(listener),
					type(listener),
					event
				),
				0
			)
		end
		etrace.subscribers[event][listener] = listener[event]
	else
		error(
			format(
				"Invalid listener %s of type %s cannot subscribe to event %s",
				tostring(listener),
				type(listener),
				event
			),
			0
		)
	end
end

function etrace.unsubscribe(event, listener)
	validateString(event, "event")

	if etrace.registeredEvents[event] == nil then
		error(
			format(
				"Cannot unsubscribe listener %s of type %s from unknown event %s",
				tostring(listener),
				type(listener),
				event
			),
			0
		)
	end

	if type(listener) ~= "function" and type(listener) ~= "table" then
		error(
			format(
				"Invalid listener %s of type %s cannot unsubscribe from event %s",
				tostring(listener),
				type(listener),
				event
			),
			0
		)
	end

	etrace.subscribers[event] = etrace.subscribers[event] or {}
	if etrace.subscribers[event][listener] == nil then
		error(
			format("Listener %s of type %s is not subscribed to event %s", tostring(listener), type(listener), event),
			0
		)
	end

	etrace.subscribers[event][listener] = nil
end

function etrace.notify(event, payload)
	payload = payload or {}

	validateString(event, "event")
	validateTable(payload, "payload")

	local subscribers = etrace.subscribers[event]
	if not subscribers then
		return
	end

	for listener, eventHandler in pairs(subscribers) do
		if type(listener) == "table" then -- Enable use of : syntax
			eventHandler(listener, event, payload)
		else -- No point in passing self
			eventHandler(event, payload)
		end
	end
end

function etrace.publish(event, payload)
	payload = payload or {}
	validateString(event, "event")
	validateTable(payload, "payload")

	etrace.record(event, payload)
	etrace.notify(event, payload)
end

return etrace
