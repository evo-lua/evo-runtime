set -e

REQUIRED_CLANG_FORMAT_VERSION="17"
CLANG_FORMAT_DOWNLOAD_URL="https://apt.llvm.org/llvm.sh"

echo "Downloading LLVM install script from $CLANG_FORMAT_DOWNLOAD_URL"
wget -O llvm.sh $CLANG_FORMAT_DOWNLOAD_URL
chmod +x llvm.sh
echo

echo "You should inspect the contents of llvm.sh (e.g. via cat llvm.sh)"
echo "Don't blindly run code that was downloaded from the internet"
echo

echo "The script will now attempt to install clang-format-$REQUIRED_CLANG_FORMAT_VERSION \n"
echo

# This should prompt the user, giving them time to inspect llvm.sh if so desired (not in CI runs)
sudo ./llvm.sh $REQUIRED_CLANG_FORMAT_VERSION
sudo apt install clang-format-$REQUIRED_CLANG_FORMAT_VERSION
echo

echo "Cleanup: Removing llvm.sh"
echo
rm -rf llvm.sh

echo $(clang-format-$REQUIRED_CLANG_FORMAT_VERSION --version)