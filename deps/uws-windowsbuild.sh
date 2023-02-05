echo Building target uwebsockets

UWS_DIR=deps/uNetworking/uWebSockets
UWS_SOURCE_DIR=$UWS_DIR/src
BUILD_DIR=ninjabuild-windows

cd $UWS_DIR

# make clean
# TBD: WITH_OPENSSL? WITH_QUIC? WITH_LIBUV=1 ? also DISABLE these: LIBUS_NO_SSL  UWS_NO_ZLIB - and use the libuv/zlib we built
make capi

cd -

#cp $UWS_SOURCE_DIR/luajit.exe $BUILD_DIR
# cp $UWS_SOURCE_DIR/libluajit.a $BUILD_DIR

# A basic smoke test like this doesn't really do much to verify that the executable works, but it can't hurt either
#$BUILD_DIR/luajit.exe -e "print(\"Hello from LuaJIT! (This is a test and can be ignored)\")"

# This is needed to save bytecode via luajit -b since the jit module isn't embedded inside the executable
#cp $UWS_SOURCE_DIR/jit/* $BUILD_DIR/jit
