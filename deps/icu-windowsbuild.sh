# pacman -S --needed autoconf automake libtool make mingw-w64-x86_64-gcc
# pacman -S autoconf-archive
# TODO out-of-source build
set -e

NUM_PARALLEL_JOBS=$(nproc)

echo "Building target icu4c with $NUM_PARALLEL_JOBS jobs"

SRC_DIR=deps/unicode-org/icu/icu4c/source
OUT_DIR=ninjabuild-windows

cd $SRC_DIR

# The ICU configure script seems to pick clang by default
export CC=gcc
export CXX=g++

# Run autoreconf to generate the latest configure script
autoreconf -i -f

# ./runConfigureICU MinGW --enable-static --disable-shared  --disable-tools --disable-tests --disable-samples 
./runConfigureICU MinGW --enable-static --enable-shared=no
#--enable-static --enable-shared=no  --enable-tools=no --enable-tests=no --enable-samples=no
# ./configure --enable-static --disable-shared  --disable-tools --disable-tests --disable-samples 
#--prefix=$BUILD_DIR 
make clean
make -j$NUM_PARALLEL_JOBS

cd -

cp $SRC_DIR/lib/*.a $OUT_DIR
