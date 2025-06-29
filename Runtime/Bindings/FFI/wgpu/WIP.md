https://github.com/webgpu-native/webgpu-headers/compare/043af6c77e566f707db36759d9c9f161ebb616fd...bac520839ff5ed2e2b648ed540bd9ec45edbccbc#diff-074fca0467717d8d789bdfb86bf9e2d4afec03055a2787e0b604fda4254d4ed9R2285

Somewhere around here:
typedef void (*WGPUProcBindGroupSetLabel)(WGPUBindGroup bindGroup, WGPUStringView label) WGPU_FUNCTION_ATTRIBUTE;

See also the docs RE async mapping and futures, ownership changes etc (this doesn't map cleanly to the FFI?):

https://github.com/webgpu-native/webgpu-headers/compare/043af6c77e566f707db36759d9c9f161ebb616fd...bac520839ff5ed2e2b648ed540bd9ec45edbccbc#diff-074fca0467717d8d789bdfb86bf9e2d4afec03055a2787e0b604fda4254d4ed9R2285

Need to test whether that's problematic and possibly change approaches here, it's not feasible to keep up with those kinds of breaking changes unless the bindings are automatically generated/wrapped in native code.