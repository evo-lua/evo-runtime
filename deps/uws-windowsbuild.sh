set -e

echo Building target uwebsockets

UWS_DIR=deps/uNetworking/uWebSockets
UWS_SOURCE_DIR=$UWS_DIR/src
BUILD_DIR=ninjabuild-windows
ABS_BUILD_DIR=$(pwd)/$BUILD_DIR

LIBUV_INCLUDE_DIR=$(pwd)/deps/luvit/luv/deps/libuv/include

cd $UWS_DIR/uSockets
make WITH_LIBUV=1 CFLAGS+="-I $LIBUV_INCLUDE_DIR"

cp uSockets.a $ABS_BUILD_DIR
cd -