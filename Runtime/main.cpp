extern "C" {
#include "libuwebsockets.h"
#include "luv.h"
#include "openssl.h"
}

#include "evo.hpp"
#include "macros.hpp"
#include "uws_ffi.hpp"
#include "webview_ffi.hpp"

#include "LuaVirtualMachine.hpp"

static void idle_cb(uv_idle_t* handle) {
	// std::cout << "idler be idling" << std::endl;
}

int main(int argc, char* argv[]) {
	LuaVirtualMachine* luaVM = new LuaVirtualMachine();

	luaVM->SetGlobalArgs(argc, argv);
	argv = uv_setup_args(argc, argv); // Required on Linux (see https://github.com/libuv/libuv/issues/2845)

	// luv sets up its metatables when initialized; deferring this may break some internals (not sure why)
	luaVM->PreloadPackage("uv", luaopen_luv);
	luaVM->PreloadPackage("openssl", luaopen_openssl);

	// The embedded libraries are statically linked in, so we require some glue code to access them via FFI
	luaVM->BindStaticLibraryExports("webview", webview_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("uws", uwebsockets_ffi::getExportsTable());

	// Some namespaces cannot be created from Lua because they store info only available in C++ land (like #defines)
	luaVM->CreateGlobalNamespace("C_Runtime");
	luaVM->AssignGlobalVariable("EVO_VERSION", "" EVO_VERSION "");

	// TODO test wss with/without this
	uv_loop_t* loop = luv_loop(luaVM->m_luaState);
	uws_get_loop_with_native(loop);

	std::string mainChunk = "local evo = require('evo'); return evo.run()";
	std::string chunkName = "=(Lua entry point, at " FROM_HERE ")";

	int success = luaVM->DoString(mainChunk, chunkName);
	if(!success) {
		PrintRuntimeError("Failed to require evo.lua", "Could not load embedded bytecode object", "Please report this problem on GitHub", FROM_HERE);
		return EXIT_FAILURE;
	}

	// uv_idle_t idler;


	// uv_idle_init(loop, &idler);

	// uv_idle_start(&idler, idle_cb);
	// uws_test((void*)loop);
	// // http_client_test();
	// uv_run(loop, UV_RUN_DEFAULT);

	// uv_loop_close(loop);

	return EXIT_SUCCESS;
}