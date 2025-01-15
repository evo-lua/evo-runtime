set -e

NUM_PARALLEL_JOBS=$(nproc)

echo "Building target openssl with $NUM_PARALLEL_JOBS jobs"

BUILD_DIR=ninjabuild-unix
OPENSSL_DIR=deps/openssl/openssl

cd $OPENSSL_DIR

OPENSSL_STATIC_FLAGS="no-pinshared no-shared"
OPENSSL_UNUSED_FEATURES="no-dso no-module no-ui-console" 
OPENSSL_UNUSED_TARGETS="no-apps no-docs no-makedepend no-tests"
OPENSSL_OPTIONAL_FEATURES="enable-ec_nistp_64_gcc_128 enable-ktls enable-tfo"
OPENSSL_FEATURE_FLAGS="$OPENSSL_UNUSED_FEATURES $OPENSSL_OPTIONAL_FEATURES $OPENSSL_UNUSED_TARGETS"
./config $OPENSSL_STATIC_FLAGS $OPENSSL_FEATURE_FLAGS

make clean
make -j $NUM_PARALLEL_JOBS

cd -

cp $OPENSSL_DIR/libcrypto.a $BUILD_DIR
cp $OPENSSL_DIR/libssl.a $BUILD_DIR
