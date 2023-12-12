#!/bin/sh
set -e

echo "Building target lua-rapidjson"

SRC_DIR=$(pwd)/deps/xpol/lua-rapidjson
BUILD_DIR="$SRC_DIR/cmakebuild-unix"
OUT_DIR=$(pwd)/ninjabuild-unix
LUAJIT_DIR=$(pwd)/deps/LuaJIT/LuaJIT
LUAJIT_SOURCE_DIR="$LUAJIT_DIR/src"

cleanup() {
    echo "Reverting CMakeLists patch (to make sure the build is idempotent)"
    cd "$SRC_DIR"
    git apply -R ../cmakebuild-static.diff
    cd -
}

trap cleanup EXIT

echo "Applying CMakeLists patch (this should hopefully be temporary)"
cd "$SRC_DIR"
git apply ../cmakebuild-static.diff
cd -

cmake -S "$SRC_DIR" -B "$BUILD_DIR" -G Ninja -DLUA_INCLUDE_DIR="$LUAJIT_SOURCE_DIR" -DCMAKE_C_COMPILER=gcc
cmake --build "$BUILD_DIR" --clean-first

cp "$BUILD_DIR/rapidjson.a" "$OUT_DIR/librapidjson.a"
