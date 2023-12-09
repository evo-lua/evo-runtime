#!/bin/sh
set -e

echo Building target uwebsockets

UWS_DIR=deps/uNetworking/uWebSockets
BUILD_DIR=ninjabuild-unix
ABS_BUILD_DIR=$(pwd)/$BUILD_DIR
LIBUV_INCLUDE_DIR=$(pwd)/deps/luvit/luv/deps/libuv/include

cd $UWS_DIR/uSockets
make WITH_LIBUV=1 CFLAGS+="-I $LIBUV_INCLUDE_DIR"

cp uSockets.a "$ABS_BUILD_DIR"
cd -

# Since uws doesn't offer an API to get its version, a bit of a hack is needed
discover_uws_version() {
	cd "$UWS_DIR"

	DISCOVERED_UWS_VERSION=$(git describe --tags --abbrev=0)
	LUA_STRING="return '$DISCOVERED_UWS_VERSION'"
	TEMP_VERSION_FILE=$ABS_BUILD_DIR/uws-version.lua

	echo "Discovered uws version: $DISCOVERED_UWS_VERSION"
	echo "Storing tag in $TEMP_VERSION_FILE"
	echo "$LUA_STRING" > "$TEMP_VERSION_FILE"

	cd -
}

discover_uws_version