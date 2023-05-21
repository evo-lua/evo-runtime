set -e

echo "Building target luv"

SRC_DIR=deps/luvit/luv
BUILD_DIR=$SRC_DIR/cmakebuild-windows
LUAJIT_SRC_DIR=deps/luajit/src
OUT_DIR=ninjabuild-windows

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_MODULE=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DLUAJIT_LIBRARIES=$LUAJIT_SRC_DIR -DCMAKE_C_COMPILER=gcc
cmake --build $BUILD_DIR --clean-first

# Technically luv also builds LuaJIT (again), but it sometimes segfaults in JIT'ed code, so use the original instead to be safe
cp $BUILD_DIR/libluv.a $OUT_DIR
cp $BUILD_DIR/deps/libuv/libuv.a $OUT_DIR
