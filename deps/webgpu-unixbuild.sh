set -e

echo "Building target wgpu-native"

SRC_DIR=$(pwd)/deps/gfx-rs/wgpu-native
BUILD_DIR=$SRC_DIR/target/release
OUT_DIR=$(pwd)/ninjabuild-unix

make -C $SRC_DIR lib-native-release

cp $BUILD_DIR/libwgpu_native.a $OUT_DIR
cp $SRC_DIR/ffi/webgpu-headers/webgpu.h $OUT_DIR

# Since wgpu doesn't offer an API to get its version, a bit of a hack is needed
discover_wgpu_version() {
	cd $SRC_DIR

	DISCOVERED_WGPU_VERSION=$(git describe --tags --abbrev=0)
	LUA_STRING="return '$DISCOVERED_WGPU_VERSION'"
	TEMP_VERSION_FILE=$OUT_DIR/wgpu-version.lua

	echo "Discovered wgpu version: $DISCOVERED_WGPU_VERSION"
	echo "Storing tag in $TEMP_VERSION_FILE"
	echo $LUA_STRING > $TEMP_VERSION_FILE

	cd -
}

discover_wgpu_version