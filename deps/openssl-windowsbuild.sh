set -e

# Beware, the magic Windows globals... This should work on all relevant systems, though?
NUM_PARALLEL_JOBS=$NUMBER_OF_PROCESSORS

echo "Building target openssl with $NUM_PARALLEL_JOBS jobs"

BUILD_DIR=ninjabuild-windows
OPENSSL_DIR=deps/openssl/openssl

cd $OPENSSL_DIR

perl Configure mingw64 no-tests no-shared no-dso

make clean
make -j $NUM_PARALLEL_JOBS

cd -

cp $OPENSSL_DIR/libcrypto.a $BUILD_DIR
cp $OPENSSL_DIR/libssl.a $BUILD_DIR