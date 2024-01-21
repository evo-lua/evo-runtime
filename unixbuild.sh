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

if which n2 > /dev/null; then # Using n2 speeds up local development as it has better change detection
    BUILD_TOOL=n2
else # Ninja works just as well and is expected to be installed in all cases (required for building deps via CMake)
    BUILD_TOOL=ninja
fi

echo "Selected build tool: $BUILD_TOOL"

# This will only work after the dependencies have been built! (Run the deps/build-X.sh scripts manually at least once)
# The reason this is excluded from the ninja build is to eliminate propagated errors that are difficult to debug/misleading
# It's much easier to see if the dependencies could be built independently and they don't usually need rebuilding anyway
$BUILD_TOOL
