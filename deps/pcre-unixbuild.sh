#!/bin/sh
set -e

echo "Building target pcre2"

OUT_DIR=ninjabuild-unix
SRC_DIR=deps/PCRE2Project/pcre2
BUILD_DIR=$SRC_DIR/cmakebuild-unix

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF -DPCRE2_SUPPORT_JIT=ON -DPCRE2_BUILD_PCRE2GREP=OFF -DPCRE2_BUILD_TESTS=OFF -DCMAKE_C_COMPILER=gcc
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/libpcre2-8.a $OUT_DIR
cp $BUILD_DIR/pcre2.h $OUT_DIR