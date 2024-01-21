set -e

echo "Building target wgpu-native"

SRC_DIR=$(pwd)/deps/gfx-rs/wgpu-native
BUILD_DIR=$SRC_DIR/target/release
OUT_DIR=$(pwd)/ninjabuild-windows

make -C $SRC_DIR lib-native-release

cp $BUILD_DIR/libwgpu_native.a $OUT_DIR
cp $SRC_DIR/ffi/webgpu-headers/webgpu.h $OUT_DIR