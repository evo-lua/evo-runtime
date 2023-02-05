echo Building target libwebsockets

SRC_DIR=deps/warmcat/libwebsockets
BUILD_DIR=$SRC_DIR/cmakebuild-windows
OUT_DIR=ninjabuild-windows

mkdir -p $OUT_DIR/libwebsockets

# Their clean target doesn't seem to be working with ninja because there may be leftover files...
rm -rf $BUILD_DIR

# TBD: WITH_OPENSSL, libuv, zlib/miniz? uses system openssl by default, should use deps/openssl one...
cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_COMPILER=gcc
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/lib/libwebsockets_static.a $OUT_DIR
cp $BUILD_DIR/include/* $OUT_DIR