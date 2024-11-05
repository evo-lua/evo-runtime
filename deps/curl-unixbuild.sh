set -e

echo "Building target curl"

SRC_DIR=deps/curl/curl
BUILD_DIR=$SRC_DIR/cmakebuild-unix
OUT_DIR=ninjabuild-unix

# TBD: ENABLE_UNICODE (Win32 only),-DWIN32_LEAN_AND_MEAN, CURL_LTO
# CURL_USE_OPENSSL
# OPENSSL_LIBRARIES 
# OPENSSL_INCLUDE_DIR

# HTTP/3 support:
# USE_OPENSSL_QUIC
# nghttp3 submodule

# HTTP/2 support:
# libnghttp2 as submodule
# NGHTTP2_INCLUDE_DIR
# NGHTTP2_LIBRARY

# C-ARES support:
# ENABLE_ARES
# Consider libuv dns
# Consider alternatives (what if all are disabled? Fallback = system or N/A?)

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_MODULE=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DCMAKE_C_COMPILER=gcc -DBUILD_CURL_EXE=OFF -DCURL_DISABLE_INSTALL=ON
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/lib/libcurl.a $OUT_DIR
# cp $BUILD_DIR/deps/libuv/libuv.a $OUT_DIR
