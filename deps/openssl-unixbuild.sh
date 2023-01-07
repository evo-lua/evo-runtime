NUM_PARALLEL_JOBS=$(nproc)

echo "Building target openssl with $NUM_PARALLEL_JOBS jobs"

BUILD_DIR=ninjabuild-unix
OPENSSL_DIR=deps/openssl/openssl

cd $OPENSSL_DIR

./config no-tests no-shared

make clean
make -j $NUM_PARALLEL_JOBS
# Should probably run those tests for releases at least, but that takes an eternity. Postponed until later...
# make test -j $NUM_PARALLEL_JOBS

cd -

cp $OPENSSL_DIR/libcrypto.a $BUILD_DIR
cp $OPENSSL_DIR/libssl.a $BUILD_DIR
