set -e

echo "Building target zlib"

OUT_DIR=ninjabuild-unix
SRC_DIR=deps/madler/zlib
BUILD_DIR=$SRC_DIR/cmakebuild-unix

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_COMPILER=gcc
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/libz.a $OUT_DIR/zlibstatic.a
cp $BUILD_DIR/zconf.h $OUT_DIR