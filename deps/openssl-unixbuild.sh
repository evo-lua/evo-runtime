set -e

NUM_PARALLEL_JOBS=$(nproc)

echo "Building target openssl with $NUM_PARALLEL_JOBS jobs"

BUILD_DIR=ninjabuild-unix
OPENSSL_DIR=deps/openssl/openssl

cd $OPENSSL_DIR

./config no-tests no-shared no-dso

make clean
make -j $NUM_PARALLEL_JOBS

cd -

cp $OPENSSL_DIR/libcrypto.a $BUILD_DIR
cp $OPENSSL_DIR/libssl.a $BUILD_DIR
