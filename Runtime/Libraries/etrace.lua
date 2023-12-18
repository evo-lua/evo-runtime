local ipairs = ipairs
local error = error
local pairs = pairs
local type = type

local format = string.format
local table_insert = table.insert

local etrace = {
	registeredEvents = {},
	eventLog = {},
}

function etrace.reset()
	etrace.registeredEvents = {}
	etrace.eventLog = {}
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
	if etrace.registeredEvents[event] == nil then
		error(format("Cannot record unknown event %s", event), 0)
	end

	if etrace.registeredEvents[event] == false then
		return
	end

	local entry = {
		name = event,
		payload = payload or {},
	}
	table_insert(etrace.eventLog, entry)
end

local table_copy = table.copy

function etrace.filter(event)
	if event == nil or (type(event) == "table" and #event == 0) then
		-- This may be modified if other events are created
		return table_copy(etrace.eventLog)
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

return etrace
