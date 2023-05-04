local changelog = {
	["v0.0.1"] = {
		-- Initial release (first C++ version)
		newFeatures = {
			"Simplistic command-line interface for running Lua scripts",
			"Mostly-complete Lua port of the NodeJS path library",
			"Builtin test runner (BDD style) and assertions library",
			"Basic HTTP and WebSockets server APIs (using uWebSockets)",
			"Embedded LuaJIT FFI bindings for webview, uws, and stduuid",
			"Embedded Lua bindings for libuv, zlib, and openssl",
			"Several extensions to the Lua standard libraries",
			"High-level API namespaces for file system access and timer management",
			"Lua library for UUID generation (via stduuid)",
		},
		breakingChanges = {
			"This version of the runtime is generally backwards-incompatible with the previous (C-based) iteration, though many APIs are still the same",
		},
	},
	["v0.0.0"] = {
		-- Initial commit (not actually releasable)
	},
}

return changelog
