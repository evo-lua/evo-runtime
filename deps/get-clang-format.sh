#!/bin/bash
set -aeuo pipefail
source .github/autoformat.env

GITHUB_ORGANIZATION="llvm"
GITHUB_REPOSITORY="llvm-project"
REQUIRED_LLVM_VERSION=$EVO_CLANGFORMAT_VERSION # Pinned via ENV file to avoid headaches in CI runs
LLVMORG_SUFFIX="llvmorg-$REQUIRED_LLVM_VERSION"
GITHUB_BASE_URL="https://github.com/$GITHUB_ORGANIZATION/$GITHUB_REPOSITORY/releases/download/$LLVMORG_SUFFIX"

echo "Downloading clang-format release for version $REQUIRED_LLVM_VERSION"

PLATFORM=$(uname)
echo "Detected platform: $PLATFORM"

case $PLATFORM in
    MINGW64_NT*|CYGWIN_NT*|MSYS_NT*)
        LLVM_ASSET_NAME="LLVM-$REQUIRED_LLVM_VERSION-Windows-X64"
        CLANG_FORMAT_EXECUTABLE="clang-format.exe"
        ;;
    Linux)
        LLVM_ASSET_NAME="LLVM-$REQUIRED_LLVM_VERSION-Linux-X64"
        CLANG_FORMAT_EXECUTABLE="clang-format"
        ;;
    Darwin)
        LLVM_ASSET_NAME="LLVM-$REQUIRED_LLVM_VERSION-macOS-ARM64"
        CLANG_FORMAT_EXECUTABLE="clang-format"
        ;;
    *)
        echo "Unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

LLVM_RELEASE_ASSET="$LLVM_ASSET_NAME.tar.xz"
TARBALL_DOWNLOAD_DIR=$(pwd)/deps
TARBALL_DOWNLOAD_FILE="$TARBALL_DOWNLOAD_DIR/$LLVM_RELEASE_ASSET"

LLVM_RELEASE_URL="$GITHUB_BASE_URL/$LLVM_RELEASE_ASSET"
echo "Fetching $LLVM_RELEASE_URL ..."
curl --location --output "$TARBALL_DOWNLOAD_FILE" "$LLVM_RELEASE_URL"

CLANG_FORMAT_PATH="$LLVM_ASSET_NAME/bin/$CLANG_FORMAT_EXECUTABLE"
echo "Unpacking $CLANG_FORMAT_PATH ..."
tar --strip-components=2 -xvf "$TARBALL_DOWNLOAD_FILE" "$CLANG_FORMAT_PATH"

chmod +x "./$CLANG_FORMAT_EXECUTABLE"

echo "Cleanup: Removing $TARBALL_DOWNLOAD_FILE ..."
rm $TARBALL_DOWNLOAD_FILE