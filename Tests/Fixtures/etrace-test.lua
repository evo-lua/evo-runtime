local etrace = require("etrace")

etrace.register("SOME_EVENT")
etrace.register("ANOTHER_EVENT")
etrace.register("NO_PAYLOAD")

etrace.record("SOME_EVENT", { 42 })
etrace.record("ANOTHER_EVENT", { hello = "world" })
etrace.record("NO_PAYLOAD")

local events = {
	{
		name = "SOME_EVENT",
		payload = { 42 },
	},
	{
		name = "ANOTHER_EVENT",
		payload = {
			hello = "world",
		},
	},
	{
		name = "NO_PAYLOAD",
		payload = {},
	},
}

local generatedTraceLog = {}
for index, event in ipairs(events) do
	table.insert(generatedTraceLog, etrace.stringify(event.name, event.payload))
end

return table.concat(generatedTraceLog, "\n")
