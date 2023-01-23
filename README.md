# evo-runtime

``evo`` is an experimental Lua runtime built on LuaJIT and libuv (inspired by [luvit](https://github.com/luvit/luvit)).

In this repository, work continues to build on the earlier prototypes, which are [evo-luvi](https://github.com/evo-lua/evo-luvi) and [evo-legacy](https://github.com/evo-lua/evo-legacy).

## Status

This is an early prototype, focusing more on native code compared to the previous iterations.

Features generally work to the extent that they're tested, which is [as comprehensively as seems practical](https://blog.izs.me/2022/11/technical-debt-is-a-choice/).

## Goals

Ever since I discovered [luvit](https://github.com/luvit/luvit) I was enamoured with the idea of a fully-featured Lua runtime that was capable enough for general-purpose programming tasks. I know there's JavaScript and Python, but they aren't the same.

And while the Luvit contributors have done an amazing job at keeping the project alive in the absence of its creator, they can't make radical changes, experiment wildly and risk breaking things left and right for their users... *but I can*.

![https://i.imgur.com/N1TuRcc.png](https://i.imgur.com/N1TuRcc.png)

That said, this project is heavily inspired by their great work, reframed in a slightly different context. Based on the lessons learned by working with luvi (and luvit), here's my general philosopy:

* Focus on rapid iteration and "just trying things" to find what works faster - and abandon what doesn't
* Eliminate non-essential features to reduce the maintenance burden
* Strong emphasis on testing and documentation

In terms of features, this is what I have in mind:

* Networking via UDP, TCP, HTTP/S, and WebSockets
* File system access, process I/O, and other system-level tasks
* Tooling for automated testing, documentation generation, and build utilities
* Optionally: Native/web-based UIs and 3D rendering (specifics are TBD)

This is a basic outline, but the roadmap obviously isn't set in stone.

## System Requirements

The supported platforms are current versions of Windows, Linux, and Mac OS X.

Automated testing covers all platforms equally:

![https://github.com/evo-lua/evo-runtime/actions/workflows/ci-windows.yml/badge.svg](https://github.com/evo-lua/evo-runtime/actions/workflows/ci-windows.yml/badge.svg)
![https://github.com/evo-lua/evo-runtime/actions/workflows/ci-linux.yml/badge.svg](https://github.com/evo-lua/evo-runtime/actions/workflows/ci-linux.yml/badge.svg)
![https://github.com/evo-lua/evo-runtime/actions/workflows/ci-mac.yml/badge.svg](https://github.com/evo-lua/evo-runtime/actions/workflows/ci-mac.yml/badge.svg)

Development happens on Windows 10 and Ubuntu. Mac OS support is given on a "best effort" basis.

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
* ``ninjabuild-unix`` (Linux or Mac OS)

There's also config files for GitHub actions and other tooling in the project root - a necessary evil.

## More Documentation

The documentation website (work in progress) can be found here:

* [https://evo-lua.github.io/](https://evo-lua.github.io/)

If something's outdated, wrong, or missing, please [open an issue](https://github.com/evo-lua/evo-lua.github.io)!
