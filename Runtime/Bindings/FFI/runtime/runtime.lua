local bdd = require("bdd")
local console = require("console")
local etrace = require("etrace")
local ffi = require("ffi")
local oop = require("oop")
local syslog = require("syslog")
local uv = require("uv")
local versions = require("versions")

local require = require

local runtime = {
	signals = {},
	aliases = {},
	submodules = versions,
	events = {
		"MODULE_SEARCH_STARTED",
		"MODULE_LOAD_REQUIRED",
	},
}

runtime.cdefs = [[

struct static_runtime_exports_table {
	// Build configuration
	const char* (*runtime_version)(void);

	// REPL
	void (*runtime_repl_start)(void);
};

]]

function runtime.initialize()
	ffi.cdef(runtime.cdefs)
	etrace.register(runtime.events)

	-- An unhandled SIGPIPE error signal will crash servers on platforms that send it
	-- This frequently happens when attempting to write to a closed socket and must be ignored
	if uv.constants.SIGPIPE then
		local sigpipeSignal = uv.new_signal()
		sigpipeSignal:start("sigpipe")
		uv.unref(sigpipeSignal)
		runtime.signals.SIGPIPE = sigpipeSignal
	end

	-- Extended standard libraries should always be made available
	require("debugx")
	require("jsonx")
	require("packagex")
	require("stringx")
	require("tablex")

	-- Global aliases for commonly-used functions are provided as convenient shorthands
	local globalAliases = {
		after = bdd.after,
		before = bdd.before,
		buffer = require("string.buffer"),
		cast = ffi.cast,
		cdef = ffi.cdef,
		class = oop.class,
		classname = oop.classname,
		define = ffi.cdef,
		describe = bdd.describe,
		dump = debug.dump,
		extend = oop.extend,
		format = string.format,
		implements = oop.implements,
		instanceof = oop.instanceof,
		it = bdd.it,
		mixin = oop.mixin,
		new = ffi.new,
		path = require("path"),
		printf = console.printf,
		sizeof = ffi.sizeof,
		typeof = ffi.typeof,
		DEBUG = syslog.debug,
		INFO = syslog.info,
		NOTICE = syslog.notice,
		WARNING = syslog.warning,
		ERROR = syslog.error,
		CRITICAL = syslog.critical,
		ALERT = syslog.alert,
		EMERGENCY = syslog.emergency,
		EVENT = etrace.publish,
	}

	for alias, target in pairs(globalAliases) do
		-- Loading is deferred since not all libraries might be available at require time
		_G[alias] = target
		runtime.aliases[alias] = target
	end

	-- High-level API namespaces that should also be made available globally (for convenience)
	_G.C_CommandLine = require("C_CommandLine")
	_G.C_FileSystem = require("C_FileSystem")
	_G.C_ImageProcessing = require("C_ImageProcessing")
	require("C_Runtime")
	_G.C_Timer = require("C_Timer")
	_G.C_WebView = require("C_WebView")

	table.insert(package.searchers, 1, runtime.search)
	_G.require = runtime.require
end

function runtime.version()
	local cStringPointer = runtime.bindings.runtime_version()
	local versionString = ffi.string(cStringPointer)

	local majorVersion, minorVersion, patchVersion = versionString:match("(%d+)%.(%d+)%.*(%d*)")
	return versionString, tonumber(majorVersion), tonumber(minorVersion), tonumber(patchVersion)
end

function runtime.search(moduleName)
	EVENT("MODULE_SEARCH_STARTED", { moduleName = moduleName })
end

function runtime.require(moduleName)
	EVENT("MODULE_LOAD_REQUIRED", { moduleName = moduleName })
	return require(moduleName)
end

return runtime
