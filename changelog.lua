local changelog = {
	["v0.0.21"] = {
		breakingChanges = {
			"Due to upstream changes, the required version of WebKitGTK has been upgraded",
			"The iconv FFI bindings now act on and return structured data instead of primitives ",
		},
		newFeatures = {
			"Added FFI bindings for libcurl's URL parsing APIs",
			"The low-level conversion interface is now part of the iconv FFI bindings",
			"Self-contained executables can now load dynamic libraries via the `vfs` API",
		},
		improvements = {
			"The built-in WebServer should no longer prevent apps from walking the event loop manually",
		},
	},
	["v0.0.20"] = {
		breakingChanges = {
			"Due to a larger rework in the RML library, its WebGPU render interface has seen significant changes",
		},
		newFeatures = {
			"Three more table utilities have been added: `table.keys`,`table.values`, and `table.shuffle`",
			"A new and experimental event-based AsyncFileReader module is now part of the file system API",
			"It's now possible to read ZIP archives while avoiding disk I/O via `miniz.new_reader_memory`",
		},
		improvements = {
			"Self-contained executables can now easily `require` scripts and `extract` files from the virtual file system",
		},
	},
	["v0.0.19"] = {
		newFeatures = {
			"LuaJIT's built-in CPU profiler can be enabled with the new `profile` command, or loaded as `profiler`",
			"A `syslog` library has been added to support formatted log messages that tie into the event system",
			"The `eval` command provides a REPL for interactive code evaluation if no arguments were passed",
			"Added a `debug` command that allows running apps in debug mode, where event logging is always enabled",
			"Two extensions have been added to the `table` library: `table.reverse` and `table.invert`",
			"The `etrace` library received support for event listeners via  `publish`,`subscribe`, and `notify`",
			"Optimized `bit` operations for C++ numerics are now available: `ceil`, `floor`, `ispow2`, and `width`",
		},
		improvements = {
			"Error details are now displayed in reverse order by `bdd` reports to reduce the need for scrolling",
			"Encoding options should correctly be passed to `json.stringify` (and not just `json.encode`)",
			"Apps can now use `json.encode` with `cdata` and other values that provide a `__tostring` metamethod",
		},
		breakingChanges = {
			"Replaced the global `EVO_VERSION` variable with `runtime.version()`, which supports multiple returns",
			"The WebGPU FFI bindings are now preloaded as `wgpu` instead of `webgpu`, providing the same API",
			"Moved `stbi.replace_pixel_color_rgba` from Lua to C++ (apps must now access it via `stbi.bindings`)",
			"The `assertions.export` method has been replaced with a new `package.open` extension",
		},
	},
	["v0.0.18"] = {
		newFeatures = {
			"Spatialized 3D audio is now available as part of the `labsound` bindings (`PannerNode` APIs)",
			"Experimental platform support for macOS 14 and the M1 architecture, as well as M1 release binaries",
			"New assertion shorthand for floating-point number comparisons: `assertApproximatelyEquals`",
		},
		improvements = {
			"Native WebGPU extension APIs, enums, and types are now supported by the `webgpu` bindings",
			"The interpreter CLI now displays the exact commit hash for embedded library versions",
		},
	},
	["v0.0.17"] = {
		newFeatures = {
			"Added a new `utf8` library for unicode string manipulation (powered by lua-utf8)",
			"Added a new `oop` library that provides some basic object-orientation utilities",
			"The new `transform.strip` function can be used to undo text transformations",
			"LPEG has returned to the runtime and is available via the`lpeg` library",
		},
		improvements = {
			"Revamped the interpreter's command-line interface with colors and better failure modes",
			"The CLI now includes a new `test` command to automatically discover and run test files",
			"Another CLi shorthand - typing `evo .` will automatically attempt to start the `main.lua` script",
			"There's now an alias for MT-generated uuids: `uuid.create` helps save some typing",
		},
		breakingChanges = {
			"The global `extend` builtin has been removed in favor of `oop.extend`",
		},
	},
	["v0.0.16"] = {
		newFeatures = {
			"Added FFI bindings for RmlUI (including a WebGPU render interface)",
			"Added FFI bindings for LabSound ",
			"glfwSetWindowIcon is now exposed via the GLFW FFI bindings",
		},
	},
	["v0.0.15"] = {
		newFeatures = {
			"Introduced a new `etrace` library for realtime event tracing",
			"Added `table.copy` (deep copy) and `table.scopy` (shallow copy) as extensions ",
		},
	},
	["v0.0.14"] = {
		newFeatures = {
			"Added table.count as a convenient shorthand for counting all elements in a table",
		},
		breakingChanges = {
			"Improved error handling in the iconv FFI bindings (some return values have changed)",
		},
	},
	["v0.0.13"] = {
		newFeatures = {
			"The interpreter CLI now supports shorthands (such as `-e` for `eval`), which enables live debugging in VS Code",
			"Added FFI bindings for several missing GLFW functions related to window management",
		},
		breakingChanges = {
			"The parameters for certain `miniz` checksum APIs have been reordered to make them easier to use in the common case (no existing state)",
		},
	},
	["v0.0.12"] = {
		newFeatures = {
			"Introduced a new `crypto` library to support password hashing and verification (using OpenSSL's Argon2 implementation)",
		},
	},
	["v0.0.11"] = {
		newFeatures = {
			"Integrated FFI bindings to `iconv` that allow converting between different character encodings",
		},
		improvements = {
			"A number of additional console colors are now supported by the `transform` library",
		},
	},
	["v0.0.10"] = {
		newFeatures = {
			"Add a function to encode TGA images to the `C_ImageProcessing` API namespace",
			"Add a function to swap pixel formats to the stbi FFI bindings",
		},
	},
	["v0.0.9"] = {
		newFeatures = {
			"Added a new `C_ImageProcessing` API namespace (higher-level convenience layer on top of the `stbi` library)",
		},
		breakingChanges = {
			"Replaced `stbi.maxBitmapSize` with format-specific functions that return more reliable results",
		},
	},
	["v0.0.8"] = {
		newFeatures = {
			"Added FFI bindings for several missing GLFW functions",
		},
	},
	["v0.0.7"] = {
		newFeatures = {
			"Added a new FFI binding for `stbi_flip_vertically_on_write` to more easily invert textures in memory",
			"Shorthands for measuring the execution time have been added as `console.startTimer` and `console.stopTimer`",
		},
		breakingChanges = {
			"All swapchain-related `webgpu` APIs have been renamed (to consistently use `swapchain` instead of `swap_chain`)",
		},
	},
	["v0.0.6"] = {
		newFeatures = {
			"Added partial bindings for the `glfw` library to help manage native windows and events",
			"Experimental FFI bindings for Mozilla's WebGPU implementation (exposed via the `webgpu` package)",
		},
	},
	["v0.0.5"] = {
		newFeatures = {
			"The runtime now includes bindings to the `miniz` library as a complimentary API to the existing `zlib` bindings",
			"Also included is a new `regex` library (powered by PCRE2) for dealing with regular expressions",
			"It's now possible to use the `evo build` command to create standalone executables from Lua apps",
		},
	},
	["v0.0.4"] = {
		newFeatures = {
			"The runtime now includes a  new `stbi` library (powered by stb) that allows converting between common image formats",
		},
		breakingChanges = {
			"Split `ReadDirectory` and `ReadDirectoryTree` (for recursive mode) in the `C_FileSystem` API namespace",
		},
	},
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
