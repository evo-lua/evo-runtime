local etrace = require("etrace")
local syslog = require("syslog")

local VIRTUAL_TIME_NOW = 12345 -- The actual value doesn't matter, just needs to be consistent

local function resetTestEnvironment()
	before(function()
		etrace.reset()
		etrace.register("SYSLOG_MESSAGE")
		etrace.enable("SYSLOG_MESSAGE")
		syslog.time = function()
			return VIRTUAL_TIME_NOW
		end
	end)

	after(function()
		etrace.reset()
		syslog.time = os.time
	end)
end

describe("syslog", function()
	describe("debug", function()
		resetTestEnvironment()
		it("should publish a DEBUG message event with the expected payload", function()
			local messageText = "This is a DEBUG message event created by the syslog library"
			syslog.debug(messageText)
			local events = etrace.filter()

			assertEquals(#events, 1)
			local syslogMessageEvent = events[1]
			assertEquals(syslogMessageEvent.name, "SYSLOG_MESSAGE")
			assertEquals(syslogMessageEvent.payload.messageText, messageText)
			assertEquals(syslogMessageEvent.payload.typeID, syslog.messageTypes.GENERIC_DEBUG_MESSAGE)
			assertEquals(syslogMessageEvent.payload.severity, syslog.severityLevels.DEBUG)
			assertEquals(syslogMessageEvent.payload.timestamp, VIRTUAL_TIME_NOW)
		end)
	end)

	describe("info", function()
		resetTestEnvironment()
		it("should publish an INFO message event with the expected payload", function()
			local messageText = "This is an INFO message event created by the syslog library"
			syslog.info(messageText)
			local events = etrace.filter()

			assertEquals(#events, 1)
			local syslogMessageEvent = events[1]
			assertEquals(syslogMessageEvent.name, "SYSLOG_MESSAGE")
			assertEquals(syslogMessageEvent.payload.messageText, messageText)
			assertEquals(syslogMessageEvent.payload.typeID, syslog.messageTypes.GENERIC_INFO_MESSAGE)
			assertEquals(syslogMessageEvent.payload.severity, syslog.severityLevels.INFO)
			assertEquals(syslogMessageEvent.payload.timestamp, VIRTUAL_TIME_NOW)
		end)
	end)

	describe("notice", function()
		resetTestEnvironment()
		it("should publish a NOTICE message event with the expected payload", function()
			local messageText = "This is a NOTICE message event created by the syslog library"
			syslog.notice(messageText)
			local events = etrace.filter()

			assertEquals(#events, 1)
			local syslogMessageEvent = events[1]
			assertEquals(syslogMessageEvent.name, "SYSLOG_MESSAGE")
			assertEquals(syslogMessageEvent.payload.messageText, messageText)
			assertEquals(syslogMessageEvent.payload.typeID, syslog.messageTypes.GENERIC_NOTICE_MESSAGE)
			assertEquals(syslogMessageEvent.payload.severity, syslog.severityLevels.NOTICE)
			assertEquals(syslogMessageEvent.payload.timestamp, VIRTUAL_TIME_NOW)
		end)
	end)

	describe("warning", function()
		resetTestEnvironment()
		it("should publish a WARNING message event with the expected payload", function()
			local messageText = "This is a WARNING message event created by the syslog library"
			syslog.warning(messageText)
			local events = etrace.filter()

			assertEquals(#events, 1)
			local syslogMessageEvent = events[1]
			assertEquals(syslogMessageEvent.name, "SYSLOG_MESSAGE")
			assertEquals(syslogMessageEvent.payload.messageText, messageText)
			assertEquals(syslogMessageEvent.payload.typeID, syslog.messageTypes.GENERIC_WARNING_MESSAGE)
			assertEquals(syslogMessageEvent.payload.severity, syslog.severityLevels.WARNING)
			assertEquals(syslogMessageEvent.payload.timestamp, VIRTUAL_TIME_NOW)
		end)
	end)

	describe("error", function()
		resetTestEnvironment()
		it("should publish an ERROR message event with the expected payload", function()
			local messageText = "This is an ERROR message event created by the syslog library"
			syslog.error(messageText)
			local events = etrace.filter()

			assertEquals(#events, 1)
			local syslogMessageEvent = events[1]
			assertEquals(syslogMessageEvent.name, "SYSLOG_MESSAGE")
			assertEquals(syslogMessageEvent.payload.messageText, messageText)
			assertEquals(syslogMessageEvent.payload.typeID, syslog.messageTypes.GENERIC_ERROR_MESSAGE)
			assertEquals(syslogMessageEvent.payload.severity, syslog.severityLevels.ERROR)
			assertEquals(syslogMessageEvent.payload.timestamp, VIRTUAL_TIME_NOW)
		end)
	end)

	describe("critical", function()
		resetTestEnvironment()
		it("should publish a CRITICAL message event with the expected payload", function()
			local messageText = "This is a CRITICAL message event created by the syslog library"
			syslog.critical(messageText)
			local events = etrace.filter()

			assertEquals(#events, 1)
			local syslogMessageEvent = events[1]
			assertEquals(syslogMessageEvent.name, "SYSLOG_MESSAGE")
			assertEquals(syslogMessageEvent.payload.messageText, messageText)
			assertEquals(syslogMessageEvent.payload.typeID, syslog.messageTypes.GENERIC_CRITICAL_MESSAGE)
			assertEquals(syslogMessageEvent.payload.severity, syslog.severityLevels.CRITICAL)
			assertEquals(syslogMessageEvent.payload.timestamp, VIRTUAL_TIME_NOW)
		end)
	end)

	describe("alert", function()
		resetTestEnvironment()
		it("should publish an ALERT message event with the expected payload", function()
			local messageText = "This is an ALERT message event created by the syslog library"
			syslog.alert(messageText)
			local events = etrace.filter()

			assertEquals(#events, 1)
			local syslogMessageEvent = events[1]
			assertEquals(syslogMessageEvent.name, "SYSLOG_MESSAGE")
			assertEquals(syslogMessageEvent.payload.messageText, messageText)
			assertEquals(syslogMessageEvent.payload.typeID, syslog.messageTypes.GENERIC_ALERT_MESSAGE)
			assertEquals(syslogMessageEvent.payload.severity, syslog.severityLevels.ALERT)
			assertEquals(syslogMessageEvent.payload.timestamp, VIRTUAL_TIME_NOW)
		end)
	end)

	describe("emergency", function()
		resetTestEnvironment()
		it("should publish an EMERGENCY message event with the expected payload", function()
			local messageText = "This is an EMERGENCY message event created by the syslog library"
			syslog.emergency(messageText)
			local events = etrace.filter()

			assertEquals(#events, 1)
			local syslogMessageEvent = events[1]
			assertEquals(syslogMessageEvent.name, "SYSLOG_MESSAGE")
			assertEquals(syslogMessageEvent.payload.messageText, messageText)
			assertEquals(syslogMessageEvent.payload.typeID, syslog.messageTypes.GENERIC_EMERGENCY_MESSAGE)
			assertEquals(syslogMessageEvent.payload.severity, syslog.severityLevels.EMERGENCY)
			assertEquals(syslogMessageEvent.payload.timestamp, VIRTUAL_TIME_NOW)
		end)
	end)

	describe("message", function()
		resetTestEnvironment()
		it("should throw if the provided message text isn't a string value", function()
			assertThrows(function()
				syslog.message(42, syslog.severityLevels.DEBUG)
			end, "Expected argument messageText to be a string value, but received a number value instead")
		end)

		it("should throw if the provided severity level isn't a number value", function()
			assertThrows(function()
				syslog.message("Almost got me there!", "42")
			end, "Expected argument severityLevel to be a number value, but received a string value instead")
		end)

		it("should throw if the provided severity level text isn't a valid syslog severity level", function()
			assertThrows(function()
				syslog.message("42 is not a valid severity level", 42)
			end, format(syslog.errorStrings.INVALID_SEVERITY_LEVEL, 42))
		end)

		it("should throw if the provided optional message ID isn't a string value", function()
			assertThrows(function()
				syslog.message("If you're gonna use it, do it right", syslog.severityLevels.DEBUG, 42)
			end, "Expected argument optionalMessageID to be a string value, but received a number value instead")
		end)
	end)
end)
