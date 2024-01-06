set -e

echo "Building target labsound"

OUT_DIR=ninjabuild-unix
SRC_DIR=deps/LabSound/LabSound
BUILD_DIR=$SRC_DIR/cmakebuild-unix

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DLABSOUND_USE_MINIAUDIO=OFF -DLABSOUND_USE_RTAUDIO=ON
cmake --build $BUILD_DIR --clean-first --config Release

PLATFORM=$(uname)
if [ "$PLATFORM" = "Darwin" ]; then
	OSX_OUT_DIR=$BUILD_DIR/bin/LabSound.framework/Versions/A/
	cp $OSX_OUT_DIR/LabSound $OUT_DIR/libLabSound.a
else
	cp $BUILD_DIR/bin/libLabSound.a $OUT_DIR
fi
cp $BUILD_DIR/bin/libLabSoundRtAudio.a $OUT_DIR
cp $BUILD_DIR/third_party/libnyquist/lib/liblibnyquist.a $OUT_DIR/libnyquist.a