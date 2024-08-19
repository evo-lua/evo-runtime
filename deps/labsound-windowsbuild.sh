set -e

echo "Building target labsound"

OUT_DIR=$(pwd)/ninjabuild-windows
SRC_DIR=$(pwd)/deps/LabSound/LabSound
BUILD_DIR=$SRC_DIR/cmakebuild-windows

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_COMPILER=gcc -DCMAKE_C_FLAGS=-fpermissive -DCMAKE_CXX_COMPILER=g++ -DLABSOUND_USE_MINIAUDIO=OFF -DLABSOUND_USE_RTAUDIO=ON
cmake --build $BUILD_DIR --clean-first --config Release

cp $BUILD_DIR/bin/libLabSound.a $OUT_DIR
cp $BUILD_DIR/bin/libLabSoundRtAudio.a $OUT_DIR
cp $BUILD_DIR/third_party/libnyquist/lib/liblibnyquist.a $OUT_DIR/libnyquist.a