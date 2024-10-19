set -ex

GITHUB_ORGANIZATION="llvm"
GITHUB_REPOSITORY="llvm-project"
REQUIRED_LLVM_VERSION="19.1.2"  # Pinned to avoid headaches in CI runs
LLVMORG_SUFFIX="llvmorg-$REQUIRED_LLVM_VERSION"
GITHUB_BASE_URL="https://github.com/$GITHUB_ORGANIZATION/$GITHUB_REPOSITORY/releases/download/$LLVMORG_SUFFIX"

echo "Downloading clang-format release for version $REQUIRED_LLVM_VERSION"

PLATFORM=$(uname)
echo "Detected platform: $PLATFORM"

# Set platform-specific variables
case $PLATFORM in
    MINGW64_NT*|CYGWIN_NT*|MSYS_NT*)
        LLVM_ASSET_NAME="LLVM-$REQUIRED_LLVM_VERSION-Windows-X64"
        EXECUTABLE_NAME="clang-format.exe"
        ;;
    Linux)
        LLVM_ASSET_NAME="LLVM-$REQUIRED_LLVM_VERSION-Linux-X64"
        EXECUTABLE_NAME="clang-format"
        ;;
    Darwin)
        LLVM_ASSET_NAME="LLVM-$REQUIRED_LLVM_VERSION-macOS-ARM64"
        EXECUTABLE_NAME="clang-format"
        ;;
    *)
        echo "Unsupported platform: $PLATFORM"
        exit 1
        ;;
esac

LLVM_ASSET_FILE="$LLVM_ASSET_NAME.tar.xz"
GITHUB_ACTIONS_DIR=$(pwd)/.github
OUTPUT_FILE_MAIN="$GITHUB_ACTIONS_DIR/$LLVM_ASSET_FILE"

# Download the release asset
DOWNLOAD_LINK_MAIN="$GITHUB_BASE_URL/$LLVM_ASSET_FILE"
echo "Fetching GitHub release asset: $DOWNLOAD_LINK_MAIN"
# curl --location --output "$OUTPUT_FILE_MAIN" "$DOWNLOAD_LINK_MAIN"

# Extract only the clang-format binary (ignore the directory structure using --strip-components)
CLANG_FORMAT_SOURCE_PATH="$LLVM_ASSET_NAME/bin/$EXECUTABLE_NAME"
echo "Unpacking $CLANG_FORMAT_SOURCE_PATH to current directory"
tar --strip-components=2 -xvf "$OUTPUT_FILE_MAIN" "$CLANG_FORMAT_SOURCE_PATH"

# Move the extracted binary to the root directory
chmod +x "./$EXECUTABLE_NAME"

# Verify the clang-format executable
./$EXECUTABLE_NAME --version
