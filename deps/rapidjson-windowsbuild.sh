set -e

echo "Building target rapidjson"

SRC_DIR=$(pwd)/deps/xpol/lua-rapidjson
OUT_DIR=$(pwd)/ninjabuild-windows
BUILD_DIR=$OUT_DIR/deps/xpol/lua-rapidjson
LUAJIT_DIR=$(pwd)/deps/LuaJIT/LuaJIT
LUAJIT_SOURCE_DIR=$LUAJIT_DIR/src
RAPIDJSON_INCLUDE_DIR=$SRC_DIR/rapidjson/include

mkdir -p $BUILD_DIR

# Replicated version detection from CMakeLists.txt
cd $SRC_DIR
DISCOVERED_VERSION_TAG=$(git describe --tags --abbrev=0)
echo "Discovered lua-rapidjson version: $DISCOVERED_VERSION_TAG"
cd -

# The CMakeLists.txt file doesn't support static builds, so homebrew it is...
echo "Compiling sources from $SRC_DIR"
echo "Using rapidjson from $RAPIDJSON_INCLUDE_DIR"

for file in $(find $SRC_DIR -name "*.cpp")
do
    file_name=$(basename $file .cpp)
    g++ -c -o $BUILD_DIR/${file_name}.o $file -I $LUAJIT_SOURCE_DIR -I $RAPIDJSON_INCLUDE_DIR -DLUA_RAPIDJSON_VERSION=\"$DISCOVERED_VERSION_TAG\" -std=c++11
done

echo "Creating static library $OUT_DIR/librapidjson.a"
ar rcs $OUT_DIR/librapidjson.a $BUILD_DIR/*.o
