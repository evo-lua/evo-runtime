set -e

echo "Building target zlib"

OUT_DIR=ninjabuild-windows
SRC_DIR=deps/madler/zlib
BUILD_DIR=$SRC_DIR/cmakebuild-windows

ZLIB_BUILD_FLAGS="-DZLIB_BUILD_EXAMPLES=OFF -DSKIP_INSTALL_ALL=ON"
cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_SHARED_LIBS=ON -DCMAKE_C_COMPILER=gcc $ZLIB_BUILD_FLAGS
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/libzlibstatic.a $OUT_DIR/zlibstatic.a
cp $BUILD_DIR/zconf.h $OUT_DIR

# The shared library version is only used as a test fixture (somewhat arbitrary choice)
TEST_APP_DIR=$(pwd)/Tests/Fixtures/dlopen-test-app
cp $BUILD_DIR/libzlib.dll $TEST_APP_DIR/zlib.dll || cp $BUILD_DIR/libzlib1.dll $TEST_APP_DIR/zlib.dll