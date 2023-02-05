echo Building target uwebsockets

UWS_DIR=deps/uNetworking/uWebSockets
UWS_SOURCE_DIR=$UWS_DIR/src
BUILD_DIR=ninjabuild-windows

# uws doesn't have a build system, and it builds usockets with options we don't want (and can't remove...)
# So we build it manually and copy that version, which should be fine since uws itself doesn't use these options
cd $UWS_DIR/uSockets
make LIBUS_USE_OPENSSL=0 ITH_LTO=0
cp uSockets.a $BUILD_DIR
cd -

cd $UWS_DIR/capi

# make clean
# TBD: WITH_OPENSSL? WITH_QUIC? WITH_LIBUV=1 ? also DISABLE these: LIBUS_NO_SSL  UWS_NO_ZLIB - and use the libuv/zlib we built
# export WITH_ZLIB=1
# export WITH_LIBUV=1
# export LIBUS_NO_SSL=1
set LIBUS_USE_OPENSSL=0
export LIBUS_USE_OPENSSL=0
# export UWS_NO_ZLIB=1
# WITH_LTO doesn't work on Windows
# WITH_LIBUV=1 WITH_LTO=0
# make capi
# todo move to ninjabuild I guess
LIBRARY_NAME=libuwebsockets
g++ -DUWS_WITH_PROXY -c -O3 -std=c++17 -lz -luv -flto -fPIC -I ../src -I ../uSockets/src $LIBRARY_NAME.cpp
ar rvs $LIBRARY_NAME.a $LIBRARY_NAME.o ../uSockets/uSockets.a

cd -

#cp $UWS_SOURCE_DIR/luajit.exe $BUILD_DIR
# cp $UWS_SOURCE_DIR/libluajit.a $BUILD_DIR

# A basic smoke test like this doesn't really do much to verify that the executable works, but it can't hurt either
#$BUILD_DIR/luajit.exe -e "print(\"Hello from LuaJIT! (This is a test and can be ignored)\")"

# This is needed to save bytecode via luajit -b since the jit module isn't embedded inside the executable
cp $UWS_DIR/capi/libuwebsockets.a $BUILD_DIR
