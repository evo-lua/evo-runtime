set -e

NUM_PARALLEL_JOBS=$(nproc)

echo "Building target icu4c with $NUM_PARALLEL_JOBS jobs"

SRC_DIR=deps/unicode-org/icu/icu4c/source
BUILD_DIR=$SRC_DIR/cmakebuild-windows
OUT_DIR=ninjabuild-windows

cd $SRC_DIR

# The ICU configure script seems to pick clang by default
export CC=gcc
export CXX=g++

./runConfigureICU MinGW --enable-static --disable-shared
make -j $NUM_PARALLEL_JOBS

cd -

cp $SRC_DIR/lib/*.a $OUT_DIR
