local ffi = require("ffi")
local bdd = require("bdd")
local console = require("console")
local etrace = require("etrace")
local oop = require("oop")
local syslog = require("syslog")

local globalAliases = {
	["after"] = bdd.after,
	["before"] = bdd.before,
	["buffer"] = require("string.buffer"),
	["class"] = oop.class,
	["classname"] = oop.classname,
	["describe"] = bdd.describe,
	["dump"] = debug.dump,
	["extend"] = oop.extend,
	["implements"] = oop.implements,
	["instanceof"] = oop.instanceof,
	["format"] = string.format,
	["it"] = bdd.it,
	["mixin"] = oop.mixin,
	["path"] = require("path"),
	["printf"] = console.printf,
	["cast"] = ffi.cast,
	["cdef"] = ffi.cdef,
	["define"] = ffi.cdef,
	["new"] = ffi.new,
	["sizeof"] = ffi.sizeof,
	["typeof"] = ffi.typeof,
	-- Capitalization avoids name clashes and emphasises the cross-cutting nature
	["DEBUG"] = syslog.debug,
	["INFO"] = syslog.info,
	["NOTICE"] = syslog.notice,
	["WARNING"] = syslog.warning,
	["ERROR"] = syslog.error,
	["CRITICAL"] = syslog.critical,
	["ALERT"] = syslog.alert,
	["EMERGENCY"] = syslog.emergency,
	["EVENT"] = etrace.publish,
}

local globalNamespaces = {
	["C_Runtime"] = C_Runtime,
}

describe("_G", function()
	for globalName, target in pairs(globalAliases) do
		it("should export global alias " .. globalName, function()
			local alias = _G[globalName]
			assert(alias == target, globalName)
		end)
	end

	for globalName, target in pairs(globalNamespaces) do
		it("should export global namespace " .. globalName, function()
			local alias = _G[globalName]
			assert(alias == target, globalName)
		end)
	end
end)
