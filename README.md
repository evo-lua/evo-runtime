# evo-runtime

``evo`` is an experimental Lua runtime built on LuaJIT and libuv, with batteries included.

## Status

Functional, but not feature complete. See issues and milestones for future plans.

## Features

Here's a selection of things you can do when running Lua scripts with Evo:

* Networking via UDP, TCP, HTTP/S, and WebSockets
* File system access, process I/O, and other system-level tasks
* Make use of the builtin test runner (including assertions library)
* Create native or web-based UIs and 3D software
* Data compression, encryption, and basic image processing

Not all of the included APIs are as user-friendly as I'd like, but that'll change.

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
