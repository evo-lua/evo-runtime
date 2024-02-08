local etrace = require("etrace")
local path = require("path") -- Not yet preloaded when the global aliases are set up
local uv = require("uv")
local validation = require("validation")

local format = string.format
local validateString = validation.validateString
local validateNumber = validation.validateNumber

-- Always register this so that scripts can use the API even if logging is currently disabled
etrace.register("SYSLOG_MESSAGE")

local SYSLOG_FACILITY_LOCAL0 = 16
local RUNTIME_EXECUTABLE_NAME = path.basename(uv.exepath(), ".exe")
local RUNTIME_PROCESS_ID = uv.os_getpid()

local syslog = {
	FACILITY_CODE = SYSLOG_FACILITY_LOCAL0,
	APPLICATION_NAME = RUNTIME_EXECUTABLE_NAME,
	PROCESS_ID = RUNTIME_PROCESS_ID,
	HOST_NAME = uv.os_gethostname(),
	severityLevels = {
		DEBUG = 7,
		INFO = 6,
		NOTICE = 5,
		WARNING = 4,
		ERROR = 3,
		CRITICAL = 2,
		ALERT = 1,
		EMERGENCY = 0,
		-- Reverse lookup-table to more easily create human-readable output
		[0] = "EMERGENCY",
		[1] = "ALERT",
		[2] = "CRITICAL",
		[3] = "ERROR",
		[4] = "WARNING",
		[5] = "NOTICE",
		[6] = "INFO",
		[7] = "DEBUG",
	},
	messageTypes = {
		DEFAULT_MESSAGE_TYPE = "DEFAULT",
		GENERIC_EMERGENCY_MESSAGE = "EMERGENCY_GENERIC",
		GENERIC_ALERT_MESSAGE = "ALERT_GENERIC",
		GENERIC_CRITICAL_MESSAGE = "CRITICAL_GENERIC",
		GENERIC_ERROR_MESSAGE = "ERROR_GENERIC",
		GENERIC_WARNING_MESSAGE = "WARNING_GENERIC",
		GENERIC_NOTICE_MESSAGE = "NOTICE_GENERIC",
		GENERIC_INFO_MESSAGE = "INFO_GENERIC",
		GENERIC_DEBUG_MESSAGE = "DEBUG_GENERIC",
	},
	errorStrings = {
		INVALID_SEVERITY_LEVEL = "Severity level %s is not a valid syslog severity level",
	},
}

syslog.time = os.time -- To allow providing an alternate clock in tests or user scripts

function syslog.message(messageText, severityLevel, optionalMessageID)
	optionalMessageID = optionalMessageID or syslog.messageTypes.DEFAULT_MESSAGE_TYPE

	validateString(messageText, "messageText")
	validateNumber(severityLevel, "severityLevel")
	validateString(optionalMessageID, "optionalMessageID")
	if not syslog.severityLevels[severityLevel] then
		error(format(syslog.errorStrings.INVALID_SEVERITY_LEVEL, severityLevel), 0)
	end

	etrace.publish("SYSLOG_MESSAGE", {
		severity = severityLevel,
		timestamp = syslog.time(),
		messageText = messageText,
		typeID = optionalMessageID,
	})
end

function syslog.emergency(messageText, optionalMessageID)
	optionalMessageID = optionalMessageID or syslog.messageTypes.GENERIC_EMERGENCY_MESSAGE
	syslog.message(messageText, syslog.severityLevels.EMERGENCY, optionalMessageID)
end

function syslog.alert(messageText, optionalMessageID)
	optionalMessageID = optionalMessageID or syslog.messageTypes.GENERIC_ALERT_MESSAGE
	syslog.message(messageText, syslog.severityLevels.ALERT, optionalMessageID)
end

function syslog.critical(messageText, optionalMessageID)
	optionalMessageID = optionalMessageID or syslog.messageTypes.GENERIC_CRITICAL_MESSAGE
	syslog.message(messageText, syslog.severityLevels.CRITICAL, optionalMessageID)
end

function syslog.error(messageText, optionalMessageID)
	optionalMessageID = optionalMessageID or syslog.messageTypes.GENERIC_ERROR_MESSAGE
	syslog.message(messageText, syslog.severityLevels.ERROR, optionalMessageID)
end

function syslog.warning(messageText, optionalMessageID)
	optionalMessageID = optionalMessageID or syslog.messageTypes.GENERIC_WARNING_MESSAGE
	syslog.message(messageText, syslog.severityLevels.WARNING, optionalMessageID)
end

function syslog.notice(messageText, optionalMessageID)
	optionalMessageID = optionalMessageID or syslog.messageTypes.GENERIC_NOTICE_MESSAGE
	syslog.message(messageText, syslog.severityLevels.NOTICE, optionalMessageID)
end

function syslog.info(messageText, optionalMessageID)
	optionalMessageID = optionalMessageID or syslog.messageTypes.GENERIC_INFO_MESSAGE
	syslog.message(messageText, syslog.severityLevels.INFO, optionalMessageID)
end

function syslog.debug(messageText, optionalMessageID)
	optionalMessageID = optionalMessageID or syslog.messageTypes.GENERIC_DEBUG_MESSAGE
	syslog.message(messageText, syslog.severityLevels.DEBUG, optionalMessageID)
end

return syslog
