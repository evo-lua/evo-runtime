echo Building target libwebsockets

SRC_DIR=deps/warmcat/libwebsockets
BUILD_DIR=$SRC_DIR/cmakebuild-windows
OUT_DIR=ninjabuild-windows

cd $SRC_DIR

# TBD: WITH_OPENSSL, libuv, zlib/miniz?
cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_MODULE=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DCMAKE_C_COMPILER=gcc
cmake --build $BUILD_DIR --clean-first

cd -



# cp $BUILD_DIR/libluv.a $OUT_DIR
# cp $BUILD_DIR/deps/libuv/libuv_a.a $OUT_DIR
