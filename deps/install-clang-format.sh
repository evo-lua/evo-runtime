#!/bin/bash
set -aeuo pipefail
source .github/autoformat.env

LLVM_SETUP_URL="https://apt.llvm.org/llvm.sh"

echo "Downloading LLVM install script from $LLVM_SETUP_URL"
wget -O llvm.sh $LLVM_SETUP_URL
chmod +x llvm.sh
echo

echo "The script will now attempt to install clang-format-$EVO_CLANGFORMAT_VERSION"
echo

./llvm.sh $EVO_CLANGFORMAT_VERSION
rm -rf llvm.sh
apt install clang-format-$EVO_CLANGFORMAT_VERSION