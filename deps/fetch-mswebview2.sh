set -e

# Should probably be the same that webview uses
MSWEBVIEW_VERSION=1.0.1150.38
# If nuget isn't installed, it doesn't seem to use the default source on first startup
DEFAULT_NUGET_SOURCE=https://api.nuget.org/v3/index.json

echo "Fetching NuGet command line"
wget https://dist.nuget.org/win-x86-commandline/latest/nuget.exe

echo "Fetching WebView2 $MSWEBVIEW_VERSION"

echo "Installing WebView2 headers"
./nuget install Microsoft.Web.Webview2 -Version $MSWEBVIEW_VERSION -Source $DEFAULT_NUGET_SOURCE -OutputDirectory ninjabuild-windows
cp $(find ninjabuild-windows/Microsoft.Web.WebView* -name "WebView2.h") ninjabuild-windows

echo "Cleaning up..."
rm nuget.exe
echo "Done!"
