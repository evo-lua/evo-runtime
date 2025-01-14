set -e

cppcheck --version

# These are unlikely to change, so hardcoding them should be fine...
INCLUDE_DIRS="-I Runtime -I Runtime/Bindings"
SRC_DIRS="Runtime/*"
IGNORE_LIST=".cppcheck"

RELEVANT_FILES=$(find $SRC_DIRS -type f \( -name '*.c' -o -name '*.cpp' \))

cppcheck --enable=all --check-level=exhaustive --error-exitcode=127 --suppressions-list=$IGNORE_LIST $INCLUDE_DIRS $RELEVANT_FILES
