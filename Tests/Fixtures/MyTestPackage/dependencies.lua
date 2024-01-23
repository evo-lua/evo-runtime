-- dependencies.lua
-- lockfile
-- manifest.lua	https://doc.rust-lang.org/cargo/reference/manifest.html
-- configure scripts (default file name below)
-- build.lua
-- install.lua
-- main.lua
-- test.lua

return { -- build.lua contents
	-- Stores information about the app itself, used for publishing releases or building LUAZIP apps
	-- Equivalent to package.json / package.lua / cargo.toml
	version = "v0.0.1", -- Tag or commit hash! Doesn't matter, just has to be a unique git ref (install command)
	author = {
		displayName = "Dr. Evil", -- No presumption about first/last name (Asian countries, etc.) - arbitrary format
		email = "the-doctor@evil.com",
	},
	buildOptions = { -- Configure the build command/output - sensible defaults?
		-- Result: TestApp.exe (Windows) / TestApp (Linux/macOS); defaults to <RootDir> if omitted
		output = "TestApp", -- Set a custom executable name for the LUAZIP app,
		entryPoint = "MyApp.lua", -- Defaults to main.lua
		forwardCommandLineArgs = true, -- If the app uses CLI args, set to true in order to "skip" the first arg, which would normally be the file name if run from the interpreter CLI
		extractFilesOnLoad = false, -- Extract to tmp dir on load (slow), required to use zipped DLL/SO
		-- Otherwise, just load the entry point, which may be enough for smaller apps (single/amalgamated file)
	},
	dependencies = { -- actually move to install.lua (dependencies are only used here)
		["webview"] = "v0.11.0", --> Implicit lookup (runtime.packages.webview)
		["evo-lua/evo-webview"] = "54151376ecd8c547a6d5012cf111fdce25e68c5b", -- Implicit github.com prefix
		["github.com/evo-lua/evo-webview"] = "main", -- Not great, but same as npm install ...@latest basically, implicit https:// prefix ofc
		["https://github.com/evo-lua/evo-webview"] = "main", -- Regular git clone
		["https://github.com/evo-lua/evo-webview.git"] = "main", -- For arbitrary source URLs (must be git repo)
	},
	schema = 1, -- Optional: Default to latest (if omitted), pinned = use older schema for this file
}

-- At build time, this file is also embedded so it's easy to query via require('') or similar

-- Constraint on a possible solution:
-- Must use libgit - no homebrew protocols
-- Must use default require - no custom import (complexity mounts up with LUAZIP)
-- Must work the same way when run from CLI vs from LUAZIP app
-- Must be transparent to the user (no opaque lockfiles/spam in the app dir)

-- Problems to solve:
-- How to initialize new packages?
-- init command = no shorthan available if install uses -i -> rename to new? (evo -n), or create (-c), or setup (-s) - TBD
-- How are packages installed?
-- evo install <nothing -> display help text if no dependencies.lua exists, install them otherwise
-- evo install https://github.com/evo-lua/evo-webview
-- evo install evo-lua/webview
-- evo install webview
-- git clone with URL (if one was given)
-- git clone from github if only org/repo were given
-- git clone latest main/master if no version was given
-- if aliased name then fetch from evo repo or built-in list of official/known packages)
-- Where?
-- <package dir>/org/repo/versionOrHash/<files>
-- dir can be changed at runtime (expose to runtime library = use stanard package.path?)
-- Flat hierarchy of all packages, identified by commit hash/tag (git ref) -> libgit compatible
-- How are they imported?
-- From CLI: Just require (Package.path should include the default package dir by default)
-- From LUAZIP: Also require (they're extracted to a temp dir, package.path adjusted, on start)
-- When LUAZIP starts: Extract contents to disk (startup times? Maybe just the entry point/DLLs)
-- Abstract version via lookup table? require("webview") = require("evo-lua.webview.54151376ecd8c547a6d5012cf111fdce25e68c5b.webview") -> cannot use version tag due to . in require being / -> use package.config or something?
-- use package.loaders (custom loaders) to do the lookup, so for each preset from runtime.packages create one that just requires the path directly
-- if user has webview.lua as well, what happens? package.loaders is already set so user file is ignored? OK I guess
-- runtime can create package.loaders for all packages in the zip app, can even support vfs lookups that way without affecting the require on disk (from CLI)
-- Reproducible builds?
-- dependencies.lua stores the exact version of all installed libraries (as a Lua table)
-- Lockfiles needed?
-- Probably not, if using hashes and a flat hierarchy?
-- dependencies.lua is effectively a lock file then?
-- Duplication?
-- Ignored, files will be small / convenience over platform headaches (simplifies everything else, a lot)
-- Binary dependencies (FFI load support)?
-- Can always ffi.load from disk, just like any other Lua module (using package.path/cpath)
-- How should the metadata / package file be organized?
-- package.lua = lit / npm style -> conflicts with package library (global standard Lua module)
-- app.lua = maybe...? not great
-- dependencies.lua = maybe... doesn't just describe the deps, though
-- separate app/deps? (install command may adjust deps, but not app settings)
-- can output reproducible JSON, but not Lua? (serialization lib missing, maybe serpent?)
-- app.json / dependencies.json = cannot require though
-- toml = also can't require, awkward format (JSON is awkward, too...)
-- file name directly corresponds to command? (evo build => build.lua, evo install = install.lua, debug.lua, main.lua, test.lua = similar to npm scripts but implicit = simpler and more elegant, but may conflict with user apps?)
