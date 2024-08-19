set -e

echo "Building target lua-openssl"

SRC_DIR=$(pwd)/deps/zhaog/lua-openssl
BUILD_DIR=$SRC_DIR/cmakebuild-unix
OUT_DIR=$(pwd)/ninjabuild-unix

LUAJIT_SRC_DIR=$(pwd)/deps/LuaJIT/LuaJIT/src
LUAJIT_LIBRARY_PATH=$OUT_DIR/libluajit.a

OPENSSL_DIR=$OUT_DIR
OPENSSL_INCLUDE_DIR=deps/openssl/openssl/include
LIBCRYPTO=$OUT_DIR/libcrypto.a
LIBSSL=$OUT_DIR/libssl.a

cleanup() {
    echo "Reverting GCC 14 diagnostics patch (to make sure the build is idempotent)"
    cd $SRC_DIR
    git apply -R ../gcc14-diagnostics-workaround.diff
    cd -
}

trap cleanup EXIT

echo "Applying GCC 14 diagnostics patch (this should hopefully be temporary)"
cd $SRC_DIR
git apply ../gcc14-diagnostics-workaround.diff
cd -

unset PKG_CONFIG_PATH # Prevent CMake from using the system OpenSSL (which may not necessarily be compatible)

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DOPENSSL_LIBRARIES=$OUT_DIR -DBUILD_SHARED_LUA_OPENSSL=OFF -DOPENSSL_ROOT_DIR=$OPENSSL_DIR -DOPENSSL_INCLUDE_DIR=$OPENSSL_INCLUDE_DIR -DLUAJIT_INCLUDE_DIRS=$LUAJIT_SRC_DIR -DLUAJIT_LIBRARIES=$LUAJIT_SRC_DIR -DLUA_INCLUDE_DIR=$LUAJIT_SRC_DIR -DLUAJIT_LIBRARIES=$LUAJIT_LIBRARY_PATH -DCMAKE_C_COMPILER=gcc -DOPENSSL_CRYPTO_LIBRARY=$LIBCRYPTO -DOPENSSL_SSL_LIBRARY=$LIBSSL -DLUA_OPENSSL_LIBTYPE=STATIC -DOPENSSL_USE_STATIC_LIBS=ON
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/openssl.a $OUT_DIR
