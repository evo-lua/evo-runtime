#!/bin/bash
set -aeuo pipefail
source .github/autoformat.env

CLANG_FORMAT="clang-format-$EVO_CLANGFORMAT_VERSION"
echo "Installed formatters:"
echo

echo "* " $(stylua --version)
echo "* " $($CLANG_FORMAT --version)
echo

echo "Formatting Lua sources ..."

stylua . --verbose

echo "Discovering C/C++ sources ..."

RELEVANT_C_FILES_TO_FORMAT=$(find . -type f -name "*.c" -print -o -name "*.h" -print -o -path "*/deps" -prune -o -path "*/ninjabuild-*" -prune)

if [ -n "$RELEVANT_C_FILES_TO_FORMAT" ]; then
	echo "Discovered C sources:"
	echo $RELEVANT_C_FILES_TO_FORMAT

	echo "Formatting C sources ..."
	$CLANG_FORMAT -i --verbose $RELEVANT_C_FILES_TO_FORMAT
else
	echo "NO relevant C sources found"
fi

RELEVANT_CPP_FILES_TO_FORMAT=$(find . -type f -name "*.cpp" -print -o -name "*.hpp" -print -o -path "*/deps" -prune -o -path "*/ninjabuild-*" -prune)
echo "Discovered C++ sources:"
echo $RELEVANT_CPP_FILES_TO_FORMAT

echo "Formatting C++ sources ..."
$CLANG_FORMAT -i --verbose $RELEVANT_CPP_FILES_TO_FORMAT
