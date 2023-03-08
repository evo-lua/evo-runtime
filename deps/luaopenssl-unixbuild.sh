set -e

echo "Building target lua-openssl"

SRC_DIR=deps/zhaog/lua-openssl
BUILD_DIR=$SRC_DIR/cmakebuild-unix
OUT_DIR=ninjabuild-unix

# Include paths must be relative to the lua-openssl directory (NOT the project root)
LUAJIT_SRC_DIR=../../LuaJIT/LuaJIT/src

# Need to pass the full path for Mac OS builds?
OPENSSL_DIR=$(pwd)/$BUILD_DIR
OPENSSL_INCLUDE_DIR=deps/openssl/openssl/include
LIBCRYPTO=$(pwd)/$BUILD_DIR/libcrypto.a
LIBSSL=$(pwd)/$BUILD_DIR/libssl.a

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DOPENSSL_LIBRARIES=$OUT_DIR -DBUILD_SHARED_LUA_OPENSSL=OFF -DOPENSSL_ROOT_DIR=$OPENSSL_DIR -DOPENSSL_INCLUDE_DIR=$OPENSSL_INCLUDE_DIR -DLUAJIT_INCLUDE_DIRS=$LUAJIT_SRC_DIR -DLUAJIT_LIBRARIES=$LUAJIT_SRC_DIR -DLUA_INCLUDE_DIR=$LUAJIT_SRC_DIR -DCMAKE_C_COMPILER=gcc -DOPENSSL_CRYPTO_LIBRARY=$LIBCRYPTO -DOPENSSL_SSL_LIBRARY=$LIBSSL -DLUA_OPENSSL_LIBTYPE=STATIC
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/openssl.a $OUT_DIR
