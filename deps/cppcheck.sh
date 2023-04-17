set -e

cppcheck --version

# These are unlikely to change, so hardcoding them should be fine...
INCLUDE_DIRS="-I Runtime -I Runtime/Bindings"
SRC_DIRS="Runtime/*"

RELEVANT_FILES=$(find $SRC_DIRS -type f \( -name '*.c' -o -name '*.cpp' -o -name '*.h' -o -name '*.hpp' \))

cppcheck --enable=all --verbose --error-exitcode=127 $INCLUDE_DIRS $RELEVANT_FILES
