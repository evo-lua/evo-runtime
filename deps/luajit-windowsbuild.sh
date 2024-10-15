set -e

# Beware, the magic Windows globals... This should work on all relevant systems, though?
NUM_PARALLEL_JOBS=$NUMBER_OF_PROCESSORS
echo "Building target luajit with $NUM_PARALLEL_JOBS jobs"

LUAJIT_DIR=deps/LuaJIT/LuaJIT
LUAJIT_SOURCE_DIR=$LUAJIT_DIR/src
BUILD_DIR=ninjabuild-windows

mkdir -p $BUILD_DIR/jit

cd $LUAJIT_DIR

make clean
make  -j $NUM_PARALLEL_JOBS BUILDMODE=static XCFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT

cd -

cp $LUAJIT_SOURCE_DIR/luajit.exe $BUILD_DIR
cp $LUAJIT_SOURCE_DIR/libluajit.a $BUILD_DIR

# A basic smoke test like this doesn't really do much to verify that the executable works, but it can't hurt either
$BUILD_DIR/luajit.exe -e "print(\"Hello from LuaJIT! (This is a test and can be ignored)\")"

# This is needed to save bytecode via luajit -b since the jit module isn't embedded inside the executable
cp $LUAJIT_SOURCE_DIR/jit/* $BUILD_DIR/jit

# This patch fixes the 'corrupt .drectve' warnings in MSYS2, but breaks MSVC (which isn't supported anyway)
sed -i 's/\/EXPORT:/-export:/g' $BUILD_DIR/jit/bcsave.lua
