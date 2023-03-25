set -e

echo Building target uwebsockets

UWS_DIR=deps/uNetworking/uWebSockets
UWS_SOURCE_DIR=$UWS_DIR/src
BUILD_DIR=ninjabuild-unix
ABS_BUILD_DIR=$(pwd)/$BUILD_DIR

cd $UWS_DIR/uSockets
make
cp uSockets.a $ABS_BUILD_DIR
cd -

# Since uws doesn't offer an API to get its version, a bit of a hack is needed
function discover_uws_version() {
	cd $UWS_DIR

	DISCOVERED_UWS_VERSION=$(git describe --tags --abbrev=0)
	LUA_STRING="return '$DISCOVERED_UWS_VERSION'"
	TEMP_VERSION_FILE=$ABS_BUILD_DIR/uws-version.lua

	echo "Discovered uws version: $DISCOVERED_UWS_VERSION"
	echo "Storing tag in $TEMP_VERSION_FILE"
	echo $LUA_STRING > $TEMP_VERSION_FILE

	cd -
}

discover_uws_version