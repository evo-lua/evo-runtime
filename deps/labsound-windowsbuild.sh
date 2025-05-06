set -e

echo "Building target labsound"

OUT_DIR=$(pwd)/ninjabuild-windows
SRC_DIR=$(pwd)/deps/LabSound/LabSound
BUILD_DIR=$SRC_DIR/cmakebuild-windows

cleanup() {
    echo "Reverting CMakeLists patch (to make sure the build is idempotent)"
    cd $SRC_DIR
    git apply -R ../cmakebuild-fixup.diff
    cd -
}

trap cleanup EXIT

echo "Applying CMakeLists patch (this should hopefully be temporary)"
cd $SRC_DIR
git apply ../cmakebuild-fixup.diff
cd -

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_COMPILER=gcc -DCMAKE_C_FLAGS=-fpermissive -DCMAKE_CXX_COMPILER=g++ -DLABSOUND_USE_MINIAUDIO=OFF -DLABSOUND_USE_RTAUDIO=ON
cmake --build $BUILD_DIR --clean-first --config Release

cp $BUILD_DIR/bin/libLabSound.a $OUT_DIR
cp $BUILD_DIR/bin/libLabSoundRtAudio.a $OUT_DIR
cp $BUILD_DIR/third_party/libnyquist/lib/liblibnyquist.a $OUT_DIR/libnyquist.a