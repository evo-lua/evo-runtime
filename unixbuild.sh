#!/bin/sh
set -e

BUILD_DIR=ninjabuild-unix
mkdir -p $BUILD_DIR

LUAJIT_EXE="$BUILD_DIR/luajit"
if ! test -f "$LUAJIT_EXE"; then
    echo "LuaJIT executable not found in $BUILD_DIR! Run the *-unixbuild scripts first."
	exit 1
fi

# For bootstrapping purposes, it's assumed LuaJIT itself can be built manually (if needed) using their own build system
$LUAJIT_EXE ninjabuild.lua

# LuaJIT's jit module is implemented in Lua and needs to be loaded via LUA_PATH for bytecode generation
export LUA_PATH="$BUILD_DIR/?.lua;./?.lua"

# This will only work after the dependencies have been built! (Run the deps/build-X.sh scripts manually at least once)
# The reason this is excluded from the ninja build is to eliminate propagated errors that are difficult to debug/misleading
# It's much easier to see if the dependencies could be built independently and they don't usually need rebuilding anyway
ninja