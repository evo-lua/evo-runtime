# evo-runtime

``evo`` is an experimental Lua runtime built on LuaJIT and libuv (inspired by [luvi](https://github.com/luvit/luvi)).

## Status

This is an early prototype, focusing more on native code compared to the previous iterations. Features generally work to the extent that they're tested, which is [as comprehensively as seems practical to balance technical debt and iteration speed](https://blog.izs.me/2022/11/technical-debt-is-a-choice/).

## System Requirements

The supported platforms are current versions of Windows, Linux, and Mac OS X.

## Repository Layout

In this repository, you'll find the following important directories:

* ``BuildTools/``: Basic tooling to generate Ninja build configurations for the runtime
* ``Dependencies/``: Third-party libraries and MSYS/Unix-compatible build scripts
* ``Runtime/``: Native glue and bootstrapping code for the Lua environment
* ``Tests/``: All kinds of automated tests and executable specs live here

There's also config files for GitHub actions and other tooling - a necessary evil.
