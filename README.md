# evo-runtime

``evo`` is an experimental Lua runtime built on LuaJIT and libuv (inspired by [luvit](https://github.com/luvit/luvit)).

In this repository, work continues to build on the earlier prototypes, which are [evo-luvi](https://github.com/evo-lua/evo-luvi) and [evo-legacy](https://github.com/evo-lua/evo-legacy).

## Status

This is an early prototype, focusing more on native code compared to the previous iterations. Features generally work to the extent that they're tested, which is [as comprehensively as seems practical](https://blog.izs.me/2022/11/technical-debt-is-a-choice/).
Consider this a successor to [evo-luvi](https://github.com/evo-lua/evo-luvi), which it will eventually replace (when this new version reaches feature parity).

## System Requirements

The supported platforms are current versions of Windows, Linux, and Mac OS X.

Automated testing covers all platforms equally:

![https://github.com/evo-lua/evo-runtime/actions/workflows/ci-windows.yml/badge.svg](https://github.com/evo-lua/evo-runtime/actions/workflows/ci-windows.yml/badge.svg)
![https://github.com/evo-lua/evo-runtime/actions/workflows/ci-linux.yml/badge.svg](https://github.com/evo-lua/evo-runtime/actions/workflows/ci-linux.yml/badge.svg)
![https://github.com/evo-lua/evo-runtime/actions/workflows/ci-mac.yml/badge.svg](https://github.com/evo-lua/evo-runtime/actions/workflows/ci-mac.yml/badge.svg)

Development happens on Windows 10 and Ubuntu. Mac OS support is given on a "best effort" basis.

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
