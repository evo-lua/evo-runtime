set -e

echo "Building target miniz"

OUT_DIR=ninjabuild-windows
SRC_DIR=deps/richgel999/miniz
BUILD_DIR=$SRC_DIR/cmakebuild-windows

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_COMPILER=gcc -DBUILD_EXAMPLES=OFF -DINSTALL_PROJECT=OFF -DAMALGAMATE_SOURCES=ON
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/libminiz.a $OUT_DIR
cp $BUILD_DIR/amalgamation/miniz.h $OUT_DIR