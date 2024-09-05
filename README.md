# evo-runtime

``evo`` is a standalone Lua runtime built on LuaJIT and libuv, with batteries included.

## Features

Here's a selection of things you can do when running Lua scripts with Evo:

* Networking via UDP, TCP, HTTP/S, and WebSockets
* File system access, process I/O, and similar system-level programming tasks
* Automated testing using the builtin test runner and assertion library
* Create native or web-based UIs, scriptable from Lua (native) or JavaScript (web)
* Develop multimedia apps with realtime audio or 3D rendering capabilities
* Data compression, encryption, and image processing
* Regular expressions, JSON, charset conversions, UTF8 strings
* Build and deploy executables that "just work" on the end-user's system

Not all of the included APIs are as user-friendly as I'd like, but that'll change.

## Status

Functional, but not feature complete. See [issues](https://github.com/evo-lua/evo-runtime/issues) and [milestones](https://github.com/evo-lua/evo-runtime/milestones) for details. Quick summary for the impatient:

* Core features: Fully implemented and tested. Package management facilities are still missing
* Documentation: Exists and is fairly comprehensive, but might be incomplete and poorly structured
* Dependencies: Currently the runtime is "bloated" on purpose, will streamline this in the Beta phase
* Interoperability: Selective for now, may consider adding additional integrations later (within reason)
* Performance optimization and security hardening: Ongoing effort, much room for improvement
* Usability: Various low-level libraries require a lot of tinkering/domain knowledge; high-level APIs are planned

Evo is a hobbyist project. There may be long periods of time with little to no activity; that's normal and expected.

### Roadmap

Below is a rough outline for the first major release (note that this list doesn't include completed features):

* [x] MVP: Experimentation and proof-of-concept (completed in multiple stages)
* [ ] Alpha: Standard libraries and inclusion of additional bindings (currently in progress; ETA: Q4/2024 - Q1/2025)
  * [ ] Coming Very Soon™: Bindings for [libcurl](https://curl.se/libcurl/)
  * [ ] Coming Soon™: Bindings for [SQLite](https://www.sqlite.org/)
  * [ ] Potentially coming in this phase (TBD): Bindings for [C-ARES](https://c-ares.org/)
  * [ ] Potentially coming in this phase (TBD): Bindings for [LibGit2](https://libgit2.org/)
  * [ ] Towards the end: Catching up on the documentation tasks that I've been neglecting (sorry)
* [ ] Beta: Package management and third-party integrations, streamlining, performance (ETA: Q1/2025 - Q3/2025)
  * [ ] Specifics TBD, but the idea is to move bulky libraries out of the runtime while making them easy to install
  * [ ] Fixing up the existing developer tools to better support Evo's custom additions is also likely to happen here
  * [ ] In some cases, slow/otherwise problematic C bindings could be replaced with more efficient FFI wrappers
  * [ ] I want to streamline the APIs and fix various inconsistencies in the libraries, which may take place here
  * [ ] Reviewing and potentially reconsidering some security-critical features is scheduled for this phase, as well
* [ ] Initial release: Adapting to feedback and potentially optimizing for more use cases (ETA: Q3/2025- Q1/2026)
  * [ ] No timelines or even specific plans here yet, but open for ideas if someone has raised valid concerns
  * [ ] Otherwise I'll just optimize for my own use cases, same as before, which may or may not be useful to others

No promises that the list will always be up-to-date, but you should now have a general idea what might be next.

### Integrated C and FFI Bindings

The runtime currently ships with bindings (and, in some cases, interoperability layers) for the following libraries:

* [GLFW](https://www.glfw.org/): For portable windowing, user input, and integration with native graphics APIs ([Docs](https://evo-lua.github.io/docs/references/api/bindings/glfw))
* [iconv](https://www.gnu.org/software/libiconv): Standard toolkit for converting between different character encodings  ([Docs](https://evo-lua.github.io/docs/references/api/bindings/iconv/))
* [libuv](https://libuv.org/): Platform-independent networking, file system access, inter-process communication, and more ([Docs](https://evo-lua.github.io/docs/references/api/bindings/uv))
* [LabSound](https://labsound.io): WebAudio implementation that can satisfy complex audio programming needs ([Docs](https://evo-lua.github.io/docs/references/api/bindings/labsound/))
* [LPEG](https://www.inf.puc-rio.br/~roberto/lpeg/): Pattern-matching library created by one of the Lua authors ([Docs](https://evo-lua.github.io/docs/references/api/bindings/lpeg/))
* [MicroWebSockets](https://github.com/uNetworking/uWebSockets): Makes it possible to create high-performance WebSocket or HTTP/S servers ([Docs](https://evo-lua.github.io/docs/references/api/bindings/uws))
* [miniz](https://github.com/richgel999/miniz): Lightweight library to work with ZIP archives, either in-memory or on disk ([Docs](https://evo-lua.github.io/docs/references/api/bindings/miniz))
* [OpenSSL3](https://www.openssl.org/): The de-facto standard for cryptography primitives and secure networking ([Docs](https://evo-lua.github.io/docs/references/api/bindings/openssl))
* [PCRE2](https://pcre2project.github.io/pcre2/): Comprehensive regular expression library for times when Lua patterns just aren't enough ([Docs](https://evo-lua.github.io/docs/references/api/bindings/regex))
* [RapidJSON](http://rapidjson.org/): Allows converting between JSON strings and Lua tables ([Docs](https://evo-lua.github.io/docs/references/api/bindings/json))
* [RML-UI](https://mikke89.github.io/RmlUiDoc/): Native user interfaces that can be defined via HTML/CSS or entirely managed from Lua ([Docs](https://evo-lua.github.io/docs/references/api/bindings/rml/))
* [stbi](https://github.com/nothings/stb/tree/master): Widely-used image processing library that supports many popular formats, like PNG, JPG, BMP, etc. ([Docs](https://evo-lua.github.io/docs/references/api/bindings/stbi))
* [stduuid](https://github.com/mariusbancila/stduuid): Helps generate and validate unique identifiers following the official UUID specification ([Docs](https://evo-lua.github.io/docs/references/api/bindings/stduuid))
* [Lua-UTF8](https://github.com/starwing/luautf8): Provides methods for dealing with unicode strings ([Docs](https://evo-lua.github.io/docs/references/api/bindings/utf8))
* [WebGPU](https://www.w3.org/TR/webgpu/): Crossplatform graphics API that - despite the name - requires neither a browser nor JavaScript ([Docs](https://evo-lua.github.io/docs/references/api/bindings/webgpu))
* [WebView](https://github.com/webview/webview): Integration with native browser engines for cases when you do, in fact, want to use JavaScript ([Docs](https://evo-lua.github.io/docs/references/api/bindings/webview/))
* [zlib](https://zlib.net/): Fully-featured compression library that complements miniz for more advanced use cases ([Docs](https://evo-lua.github.io/docs/references/api/bindings/zlib/))

Note that some of these are still limited to the slower C API, while others make use of LuaJIT's [FFI](https://luajit.org/ext_ffi.html) already.

### Non-Standard Libraries

There's also a number of standalone - but somewhat experimental - Lua modules that I'm still iterating on:

* An [assertions](https://evo-lua.github.io/docs/references/api/libraries/assertions/) library that's heavily used by the built-in test runner
* A transparent [unit testing library](https://evo-lua.github.io/docs/references/api/libraries/bdd/) that supports several different paradigms and shorthands
* Some utilities for manipulating [console](https://evo-lua.github.io/docs/references/api/libraries/console/) output
* Password hashing functions using Argon2 (via OpenSSL/libargon2) live in the [crypto](https://github.com/evo-lua/evo-runtime/blob/main/Runtime/Libraries/crypto.lua) library
* Event notifications and tracing mechanisms are implemented in the [etrace](https://github.com/evo-lua/evo-runtime/blob/main/Runtime/Libraries/etrace.lua) library
* A few handy shorthands for typical object-oriented programming tasks can be found in the [oop](https://github.com/evo-lua/evo-runtime/blob/main/Runtime/Libraries/oop.lua) library
* A port of the NodeJS [path](https://evo-lua.github.io/docs/references/api/libraries/path/) library handles platform differences and path resolution
* Logging primitives are contained in the [syslog](https://github.com/evo-lua/evo-runtime/blob/main/Runtime/Libraries/syslog.lua) package
* Colored console output and pretty-printing is possible thanks to the [transform](https://evo-lua.github.io/docs/references/api/libraries/transform/) library
* Generating UUIDs is made a bit easier by the [uuid](https://evo-lua.github.io/docs/references/api/libraries/uuid/) library, which abstracts the underlying FFI bindings
* Validation of arguments and standardized error messages are handled by the [validation](https://evo-lua.github.io/docs/references/api/libraries/validation/) library
* Generating standalone executables and access to the virtual file system requires the [vfs](https://evo-lua.github.io/docs/references/api/libraries/vfs/) library

For a comprehensive list of functionality available in the latest release, check out the [API documentation](https://evo-lua.github.io/docs/category/api).

### Builtin Extensions and Global Aliases

There's a number of [nonstandard extensions](https://evo-lua.github.io/docs/references/api/extensions):

* Inspection of Lua tables becomes trivial with the builtin `dump` utility - even without a debugger
* More efficient power-of-two math and some other operations have been added to the `bit` library
* Various (non-optimized) utility methods are now part of the `debug`, `string`, and `table` libraries
* Several commonly used functions are also available as [global aliases](https://evo-lua.github.io/docs/references/api/globals), which have proved handy so far
* One of the simplest examples would be the ubiquitous `printf` function, which aliases `print(format(...))`

Extensions like these are usually added for convenience, to make debugging easier, or for performance reasons.

## System Requirements

The supported platforms are current versions of Windows, Linux, and macOS.

Automated testing covers all platforms equally:

![https://github.com/evo-lua/evo-runtime/actions/workflows/ci-windows.yml/badge.svg](https://github.com/evo-lua/evo-runtime/actions/workflows/ci-windows.yml/badge.svg)
![https://github.com/evo-lua/evo-runtime/actions/workflows/ci-linux.yml/badge.svg](https://github.com/evo-lua/evo-runtime/actions/workflows/ci-linux.yml/badge.svg)
![https://github.com/evo-lua/evo-runtime/actions/workflows/ci-mac.yml/badge.svg](https://github.com/evo-lua/evo-runtime/actions/workflows/ci-mac.yml/badge.svg)

Development happens on Windows 10 and Ubuntu; macOS (especially M1) support is given on a "best effort" basis.

## Compatibility

Evo is **fully compatible** with:

* PUC Lua 5.1
* LuaJIT (latest)
* Developer tools - like VS Code extensions - that support the above language versions

It is **generally incompatible** with:

* PUC Lua 5.2, 5.3, or 5.4 (though some 5.2 and 5.3 APIs are supported)
* Any LuaJIT fork that strays too far from upstream (it's dangerous out there!)
* Embedded Lua(u) environments, like those found in games (ROBLOX, WOW, ...)

I have *no plans* to support Lua engines other than LuaJIT at this time.

## Repository Layout

In this repository, you'll find the following important directories:

* ``BuildTools/``: Basic tooling to generate Ninja build configurations for the runtime
* ``deps/``: Third-party libraries and MSYS/Unix-compatible build scripts
* ``Runtime/``: Native glue and bootstrapping code for the Lua environment
* ``Tests/``: All kinds of automated tests and executable specs live here

After building, you'll additionally find a temporary directory containing all build artifacts here:

* ``ninjabuild-windows`` (Windows)
* ``ninjabuild-unix`` (Linux or macOS)

There's also config files for GitHub actions and other tooling in the project root - a necessary evil.

## More Documentation

The documentation website (work in progress) can be found here:

* [https://evo-lua.github.io/](https://evo-lua.github.io/)

If something's outdated, wrong, or missing, please [open an issue](https://github.com/evo-lua/evo-lua.github.io)!
