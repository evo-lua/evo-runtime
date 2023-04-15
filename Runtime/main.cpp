extern "C" {
#include "luv.h"
#include "lzlib.hpp"
#include "openssl.h"
}

#include "evo.hpp"
#include "macros.hpp"
#include "stduuid_ffi.hpp"
#include "uws_ffi.hpp"
#include "webview_ffi.hpp"

#include "LuaVirtualMachine.hpp"

int main(int argc, char* argv[]) {
	LuaVirtualMachine* luaVM = new LuaVirtualMachine();

	luaVM->SetGlobalArgs(argc, argv);
	argv = uv_setup_args(argc, argv); // Required on Linux (see https://github.com/libuv/libuv/issues/2845)

	// luv sets up its metatables when initialized; deferring this may break some internals (not sure why)
	luaVM->PreloadPackage("uv", luaopen_luv);
	luaVM->PreloadPackage("openssl", luaopen_openssl);
	luaVM->PreloadPackage("zlib", luaopen_zlib);

	// The embedded libraries are statically linked in, so we require some glue code to access them via FFI
	luaVM->BindStaticLibraryExports("webview", webview_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("uws", uws_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("stduuid", stduuid_ffi::getExportsTable());

	// Some namespaces cannot be created from Lua because they store info only available in C++ land (like #defines)
	luaVM->CreateGlobalNamespace("C_Runtime");
	luaVM->AssignGlobalVariable("EVO_VERSION", "" EVO_VERSION "");

	// A bit of a hack; Can't use uv_default_loop because luv maintains a separate "default" loop of its own
	uv_loop_t* loop = luv_loop(luaVM->GetState());
	uws_ffi::assignEventLoop(loop);

	std::string mainChunk = "local evo = require('evo'); return evo.run()";
	std::string chunkName = "=(Lua entry point, at " FROM_HERE ")";

	int success = luaVM->DoString(mainChunk, chunkName);
	if(!success) {
		PrintRuntimeError("Failed to require evo.lua", "Could not load embedded bytecode object", "Please report this problem on GitHub", FROM_HERE);
		return EXIT_FAILURE;
	}

	uv_run(loop, UV_RUN_DEFAULT);

	return EXIT_SUCCESS;
}