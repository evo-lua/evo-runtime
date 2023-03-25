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

# Since uws doesn't offer an API to get its version, this hack makes discovering the version "easy"
cd $UWS_DIR
git describe --tags --abbrev=0 > ../UWS_VERSION.out
cd -

cp $UWS_DIR/capi/libuwebsockets.a $BUILD_DIR
