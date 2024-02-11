local bindings = require("bindings")
local ffi = require("ffi")

local webview = {}

function webview.initialize()
	ffi.cdef(bindings.webview.cdefs)
end

function webview.version()
	local versionInfo = webview.bindings.webview_version()
	local luaVersionString = ffi.string(versionInfo.version_number)
	return luaVersionString
end

return webview
