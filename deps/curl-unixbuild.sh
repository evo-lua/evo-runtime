set -e

echo "Building target curl"

SRC_DIR=deps/curl/curl
BUILD_DIR=$SRC_DIR/cmakebuild-unix
OUT_DIR=ninjabuild-unix

# TBD: ENABLE_ARES, ENABLE_UNICODE (Win32 only),-DWIN32_LEAN_AND_MEAN, CURL_LTO
# TBD OpenSSL path? USE_OPENSSL

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_MODULE=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DCMAKE_C_COMPILER=gcc -DBUILD_CURL_EXE=OFF -DCURL_DISABLE_INSTALL=ON
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/lib/libcurl.a $OUT_DIR
# cp $BUILD_DIR/deps/libuv/libuv.a $OUT_DIR
