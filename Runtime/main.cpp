extern "C" {
#include "luv.h"
}

#include "evo.hpp"
#include "macros.hpp"
#include "webview_ffi.hpp"

#include "LuaVirtualMachine.hpp"

int main(int argc, char* argv[]) {
	LuaVirtualMachine* luaVM = new LuaVirtualMachine();

	luaVM->SetGlobalArgs(argc, argv);
	argv = uv_setup_args(argc, argv); // Required on Linux (see https://github.com/libuv/libuv/issues/2845)

	// luv sets up its metatables when initialized; deferring this may break some internals (not sure why)
	luaVM->PreloadPackage("uv", luaopen_luv);

	// The embedded libraries are statically linked in, so we require some glue code to access them via FFI
	luaVM->BindStaticLibraryExports("webview", webview_ffi::getExportsTable());

	std::string mainChunk = "local evo = require('evo'); return evo.run()";
	std::string chunkName = "=(Lua entry point, at " FROM_HERE ")";

	int success = luaVM->DoString(mainChunk, chunkName);
	if(!success) {
		PrintRuntimeError("Failed to require evo.lua", "Could not load embedded bytecode object", "Please report this problem on GitHub", FROM_HERE);
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}