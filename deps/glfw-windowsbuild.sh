set -e

echo "Building target glfw"

OUT_DIR=ninjabuild-windows
SRC_DIR=deps/glfw/glfw
BUILD_DIR=$SRC_DIR/cmakebuild-windows

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_COMPILER=gcc -DGLFW_BUILD_EXAMPLES=OFF -DGLFW_BUILD_TESTS=OFF -DGLFW_BUILD_DOCS=OFF -DGLFW_INSTALL=OFF
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/src/libglfw3.a $OUT_DIR
