set -e

# All this MUST be ran from MSYS2! OpenSSL's build system is the stuff of nightmares, and doesn't work with native perl
#The standard gcc won't work either, so make sure to install this one first (and all the other tools required):
# pacman -S git make mingw-w64-x86_64-gcc ninja mingw-w64-x86_64-cmake --noconfirm

# Beware, the magic Windows globals... This should work on all relevant systems, though?
NUM_PARALLEL_JOBS=$NUMBER_OF_PROCESSORS

echo "Building target openssl with $NUM_PARALLEL_JOBS jobs"

BUILD_DIR=ninjabuild-windows
OPENSSL_DIR=deps/openssl/openssl

cd $OPENSSL_DIR

perl Configure mingw64 no-tests no-shared

make clean
make -j $NUM_PARALLEL_JOBS
# Should probably run those tests for releases at least, but that takes an eternity. Postponed until later...
# make test -j $NUM_PARALLEL_JOBS$

cd -

mv $OPENSSL_DIR/libcrypto.a $BUILD_DIR
mv $OPENSSL_DIR/libssl.a $BUILD_DIR