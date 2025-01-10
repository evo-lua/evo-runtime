set -e

OUT_DIR=$(pwd)/ninjabuild-windows
SRC_DIR=$(pwd)/deps/freetype/freetype
BUILD_DIR=$SRC_DIR/cmakebuild-windows
LUAJIT_SRC_DIR=$(pwd)/deps/LuaJIT/LuaJIT/src
LUAJIT_LIBRARY_PATH=$OUT_DIR/libluajit.a

echo "Building target freetype"

FREETYPE_INCLUDE_DIR=$(pwd)/deps/freetype/freetype/include
FREETYPE_LIBRARY_PATH=$OUT_DIR/libfreetype.a

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja -DCMAKE_BUILD_TYPE=Release  -DFT_DISABLE_BZIP2=ON -DFT_DISABLE_PNG=ON -DFT_DISABLE_HARFBUZZ=ON -DFT_DISABLE_BROTLI=ON -DCMAKE_C_COMPILER=gcc -DSKIP_INSTALL_ALL=ON -DZLIB_LIBRARY=$OUT_DIR/zlib.a
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/libfreetype.a $OUT_DIR

echo "Building target rmlui"

SRC_DIR=deps/mikke89/RmlUi
BUILD_DIR=$SRC_DIR/cmakebuild-windows

FEATURE_FLAGS="-D BUILD_TESTING=OFF -D RMLUI_SAMPLES=OFF -D BUILD_SHARED_LIBS=OFF -D RMLUI_LUA_BINDINGS=ON -D RMLUI_LUA_BINDINGS_LIBRARY=luajit -D RMLUI_MATRIX_ROW_MAJOR=ON"
LUAJIT_INCLUDES="-D LUAJIT_LIBRARY=$LUAJIT_LIBRARY_PATH -D LUAJIT_INCLUDE_DIR=$LUAJIT_SRC_DIR"
FREETYPE_INCLUDES="-D FREETYPE_INCLUDE_DIRS=$FREETYPE_INCLUDE_DIR -D FREETYPE_LIBRARY=$FREETYPE_LIBRARY_PATH"
LIBRARY_INCLUDES="$LUAJIT_INCLUDES $FREETYPE_INCLUDES"

cmake -S $SRC_DIR -B $BUILD_DIR -G Ninja $FEATURE_FLAGS -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ $LIBRARY_INCLUDES -DCMAKE_BUILD_TYPE=Release
cmake --build $BUILD_DIR --clean-first

cp $BUILD_DIR/librmlui.a $OUT_DIR
cp $BUILD_DIR/librmlui_lua.a $OUT_DIR