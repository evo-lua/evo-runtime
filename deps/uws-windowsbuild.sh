set -e

echo Building target uwebsockets

UWS_DIR=deps/uNetworking/uWebSockets
UWS_SOURCE_DIR=$UWS_DIR/src
BUILD_DIR=ninjabuild-windows
ABS_BUILD_DIR=$(pwd)/$BUILD_DIR

cd $UWS_DIR/uSockets
make
cp uSockets.a $ABS_BUILD_DIR
cd -

cp $UWS_DIR/capi/libuwebsockets.a $BUILD_DIR
