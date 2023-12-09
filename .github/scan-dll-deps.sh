#!/bin/sh
set -e

echo "Scanning for unwanted DLL dependencies ..."
objdump -p ninjabuild-windows/evo.exe | grep "DLL Name" > ninjabuild-windows/dlls.txt

echo "Found DLL dependencies:"
cat ninjabuild-windows/dlls.txt

# Check for non-Windows DLLs that prevent standalone apps from running
for lib in "libgcc" "libwinpthread" "libstdc++"; do
  if grep -q "$lib" ninjabuild-windows/dlls.txt; then
    echo "✗ Detected a dynamic dependency on $lib"
    exit 1
  fi
done

echo "✓ No undesirable DLL dependencies detected"
