echo "Building target libuv"

SRC_DIR=Dependencies/libuv/libuv
BUILD_DIR=$SRC_DIR/cmakebuild-unix
OUT_DIR=ninjabuild-unix

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_SHARED_LIBS=OFF -DLIBUV_BUILD_TESTS=OFF -DCMAKE_C_COMPILER=gcc
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/libuv_a.a $OUT_DIR
