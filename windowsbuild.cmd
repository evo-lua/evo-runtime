@echo off

SET BUILD_DIR=ninjabuild-windows
IF NOT EXIST "%BUILD_DIR%" mkdir %BUILD_DIR%

SET LUAJIT_EXE="%BUILD_DIR%\luajit.exe"
IF NOT EXIST %LUAJIT_EXE% (
	ECHO LuaJIT executable not found in %BUILD_DIR%! Run the *-windowsbuild scripts first.
	EXIT /B 1
)

REM For bootstrapping purposes, it's assumed LuaJIT itself can be built manually (if needed) using their own build system
%LUAJIT_EXE% ninjabuild.lua

REM LuaJIT's jit module is implemented in Lua and needs to be loaded via LUA_PATH for bytecode generation
SET LUA_PATH=%BUILD_DIR%\?.lua;.\?.lua

REM This will only work after the dependencies have been built! (Run the Dependencies/build-X.cmd scripts manually at least once)
REM The reason this is excluded from the ninja build is to eliminate propagated errors that are difficult to debug/misleading
REM It's much easier to see if the dependencies could be built independently and they don't usually need rebuilding anyway
ninja