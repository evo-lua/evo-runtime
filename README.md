# evo-runtime

``evo`` is an experimental Lua runtime built on LuaJIT and libuv, with batteries included.

## Status

Functional, but not feature complete. See issues and milestones for future plans. Here's a quick summary for the impatient:

* [x] MVP: Experimentation and proof-of-concept (completed in multiple stages lasting from approximately 2021 to 2023)
* [ ] Alpha: Standard libraries and inclusion of additional bindings (currently in progress; ETA: Q4/2024 - Q1/2025)
  * [ ] Bindings for [libcurl](https://curl.se/libcurl/)
  * [ ] Bindings for [SQLite](https://www.sqlite.org/)
  * [ ] Bindings for [LibGit2](https://libgit2.org/)
* [ ] Beta: Package management and third-party integrations, followed by streamlining/performance work (ETA: Q1/2025 - Q3/2025)
* [ ] Initial release: Adapting to feedback and potentially optimizing for critical use cases (ETA: Q3/2025- Q1/2026)

No promises that the list will always be up-to-date, but it should give you a vague idea of the missing core features.

## Features

Here's a selection of things you can do when running Lua scripts with Evo:

* Networking via UDP, TCP, HTTP/S, and WebSockets
* File system access, process I/O, and other system-level tasks
* Make use of the builtin test runner (including assertions library)
* Create native or web-based UIs and 3D software
* Data compression, encryption, and basic image processing

Not all of the included APIs are as user-friendly as I'd like, but that'll change.

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
* [Lua-UTF8](https://github.com/starwing/luautf8): Provides methods for dealing with Unicode strings ([Docs](https://evo-lua.github.io/docs/references/api/bindings/utf8))
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

### Extensions

There's a number of [nonstandard extensions](https://evo-lua.github.io/docs/references/api/extensions):

* Inspection of Lua tables becomes trivial with the builtin `dump` utility - even without a debugger
* More efficient power-of-two math and some other operations have been added to the `bit` library
* Various (non-optimized) utility methods are now part of the `debug`, `string`, and `table` libraries
* Several commonly used functions are also available as [global aliases](https://evo-lua.github.io/docs/references/api/globals)
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

## Why Does This Project Exist?

I started working on Evo because I wanted to write larger applications using Lua, but found the library ecosystem to be lacking.

### Development Timeline

Originally, I used [Luvit](https://luvit.io/) - and still do, occasionally. Unfortunately, it wasn't quite up to the tasks I had in mind. In between attempts to improve its runtime and learning how it works at a deeper level, I created a customized fork called [evo-luvi](https://github.com/evo-lua/evo-luvi) (now obsolete/unmaintained) and even experimented with a [Luvit-inspired runtime built on top of it](https://github.com/evo-lua/evo-legacy) (also abandoned).

As a result of creating these experiments, I gained insights that prompted me to create my own runtime, focusing on slightly different use cases and making some different technology choices. I believe those choices have already more than paid off.

To be clear: It's not my goal to "replace" Luvit, only to provide better runtime support for a select few of my other long-term projects. I still contribute and aim to advance Luvit when I can and I hope that, one day, there will be a modernized version resolving its major issues. And who knows, maybe the knowledge gained from building Evo can carry over when that day finally comes ;)

### Primary Goals

Given the above context, I formulated a set of goals guiding the future development of this platform:

* Jump-start the creation of complex Lua-based applications without having to do the embedding and integration work every time
* Provide isolated interfaces where possible, so that advanced users who want to build their own environments can still use them
* For ease of use, integrate developer tools for common tasks like running tests, generating documentation, or profiling/debugging
* Focus on LuaJIT as the only supported engine to hopefully get the best performance via exclusive features like the FFI
* Ensure to provide APIs at different levels of abstraction so that users can select the most appropriate one for the task at hand
* In the long term, consider migrating C API bindings for performance-critical parts to the FFI (or the C++ core if needed)

Basically, if you want to write applications in Lua but you don't know C/C++, you should still be able to get the job done (you'll likely re-evaluate as you naturally gain more experience). If you don't currently need the fine-grained control and superior performance of compiled languages, it should be a sensible idea to at least start prototyping with Evo and then take it from there. If you're already familiar with Lua 5.1/LuaJIT, you shouldn't be subjected to nasty surprises that leave you floundering. And finally, you shouldn't be frustrated by lacking documentation, incomprehensible source code, or untested/broken functionality.

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
