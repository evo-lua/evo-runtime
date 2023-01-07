echo "Building target pcre2"

OUT_DIR=ninjabuild-unix
SRC_DIR=deps/pcre2
BUILD_DIR=$SRC_DIR/cmakebuild-unix

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=OFF -DPCRE2_SUPPORT_JIT=ON -DCMAKE_C_COMPILER=gcc
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/libpcre2-8.a $OUT_DIR
cp $BUILD_DIR/pcre2.h $OUT_DIR