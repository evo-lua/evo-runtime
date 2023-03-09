set -e

echo "Building target lua-openssl"

SRC_DIR=deps/zhaog/lua-openssl
BUILD_DIR=$SRC_DIR/cmakebuild-windows
OUT_DIR=ninjabuild-windows

# Include paths must be relative to the lua-openssl directory (NOT the project root)
LUAJIT_SRC_DIR=../../LuaJIT/LuaJIT/src

OPENSSL_DIR=$BUILD_DIR
OPENSSL_INCLUDE_DIR=deps/openssl/openssl/include

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DOPENSSL_LIBRARIES=$OUT_DIR -DBUILD_SHARED_LUA_OPENSSL=OFF -DOPENSSL_ROOT_DIR=$OPENSSL_DIR -DOPENSSL_INCLUDE_DIR=$OPENSSL_INCLUDE_DIR -DLUAJIT_LIBRARIES=$LUAJIT_SRC_DIR -DLUAJIT_INCLUDE_DIRS=$LUAJIT_SRC_DIR -DLUA_INCLUDE_DIR=$LUAJIT_SRC_DIR -DCMAKE_C_COMPILER=gcc -DLUA_OPENSSL_LIBTYPE=STATIC
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/openssl.a $OUT_DIR
