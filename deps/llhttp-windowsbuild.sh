set -e

echo "Building target llhttp"

SRC_DIR=deps/nodejs/llhttp
BUILD_DIR=$SRC_DIR/cmakebuild-windows
OUT_DIR=ninjabuild-windows

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DCMAKE_C_COMPILER=gcc
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/libllhttp.a $OUT_DIR
