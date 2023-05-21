local changelog = {
	["v0.0.3"] = {
		newFeatures = {
			"The runtime now includes a  new `json` library (powered by rapidjson) that allows converting between JSON strings and Lua tables",
			"A new `MakeDirectoryTree` function has been added to the `C_FileSystem` API; it recursively creates any parent directories that are missing",
		},
		improvements = {
			"Native WebViews created via the `C_WebView` API should no longer be invisible on Mac OS when the window's dimensions haven't been explicitly set",
		},
	},
	["v0.0.2"] = {
		improvements = {
			"The MSYS2 standard library DLLs are no longer required to run on Windows",
		},
		newFeatures = {
			"High-level API namespace for managing embedded WebViews",
			"WebViews can toggle between fullscreen and windowed mode",
			"Scripts can now programmatically set the app icon for native WebView windows",
			"Added a new `string.filesize` extension to create human-readable formatted size strings (with units)",
		},
	},
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
