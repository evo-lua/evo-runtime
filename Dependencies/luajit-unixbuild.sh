echo Building target luajit

LUAJIT_DIR=deps/luv/deps/luajit
LUAJIT_SOURCE_DIR=$LUAJIT_DIR/src
BUILD_DIR=ninjabuild-unix

mkdir -p $BUILD_DIR/jit

cd $LUAJIT_DIR

# TBD Use whatever is available in GH Actions?
export MACOSX_DEPLOYMENT_TARGET="10.12"
make clean
make BUILDMODE=static XCFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT

cd -

cp $LUAJIT_SOURCE_DIR/luajit $BUILD_DIR
cp $LUAJIT_SOURCE_DIR/libluajit.a $BUILD_DIR

# A basic smoke test like this doesn't really do much to verify that the executable works, but it can't hurt either
$BUILD_DIR/luajit -e "print(\"Hello from LuaJIT! (This is a test and can be ignored)\")"

# This is needed to save bytecode via luajit -b since the jit module isn't embedded inside the executable
cp $LUAJIT_SOURCE_DIR/jit/* $BUILD_DIR/jit
