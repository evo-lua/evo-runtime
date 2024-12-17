extern "C" {
#include "lpeg.hpp"
#include "luv.h"
#include "luajit_repl.h"
#include "lminiz.hpp"
#include "lrexlib.hpp"
#include "lutf8.hpp"
#include "lzlib.hpp"
#include "openssl.h"
}

#include "macros.hpp"
#include "crypto_ffi.hpp"
#include "cpp_ffi.hpp"
#include "glfw_ffi.hpp"
#include "iconv_ffi.hpp"
#include "interop_ffi.hpp"
#include "labsound_ffi.hpp"
#include "rapidjson.hpp"
#include "runtime_ffi.hpp"
#include "rml_ffi.hpp"
#include "stbi_ffi.hpp"
#include "stduuid_ffi.hpp"
#include "uws_ffi.hpp"
#include "wgpu_ffi.hpp"
#include "webview_ffi.hpp"

#include "LuaVirtualMachine.hpp"
#include "SharedEventLoop.hpp"

int main(int argc, char* argv[]) {
	std::shared_ptr<LuaVirtualMachine> luaVM = std::make_shared<LuaVirtualMachine>();

	argv = uv_setup_args(argc, argv); // Required on Linux (see https://github.com/libuv/libuv/issues/2845)
	auto L = luaVM->GetState();
	luaVM->SetGlobalArgs(argc, argv);

	// In order to support multiple guests on the event loop, the runtime itself must own it
	std::unique_ptr<SharedEventLoop> sharedEventLoop = std::make_unique<SharedEventLoop>(luaVM);

	luaVM->LoadPackage("uv", luaopen_luv);
	luaVM->LoadPackage("lpeg", luaopen_lpeg);
	luaVM->LoadPackage("miniz", luaopen_miniz);
	luaVM->LoadPackage("openssl", luaopen_openssl);
	luaVM->LoadPackage("regex", luaopen_rex_pcre2);
	luaVM->LoadPackage("json", luaopen_rapidjson_modified);
	luaVM->LoadPackage("utf8", luaopen_utf8);
	luaVM->LoadPackage("zlib", luaopen_zlib);

	// This package exports APIs for the embedded libraries; they're statically linked in and can't just use require
	// Some glue code is needed to access them via FFI, but calls have lower overhead and they're easier to extend
	luaVM->LoadPackage("bindings");
	luaVM->BindStaticLibraryExports("cpp", cpp_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("crypto", crypto_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("glfw", glfw_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("iconv", iconv_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("interop", interop_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("labsound", labsound_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("webview", webview_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("uws", uws_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("rml", rml_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("runtime", runtime_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("stbi", stbi_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("stduuid", stduuid_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("wgpu", wgpu_ffi::getExportsTable());

	// Some namespaces cannot be created from Lua because they store info only available in C++ land (like #defines)
	luaVM->CreateGlobalNamespace("C_Runtime");

	runtime_ffi::assignLuaState(L);
	rml_ffi::assignLuaState(L);

	std::string mainChunk = "local evo = require('evo'); return evo.run()";
	std::string chunkName = "=(Lua entry point, at " FROM_HERE ")";

	int success = luaVM->DoString(mainChunk, chunkName);
	if(!success) {
		std::cerr << "\t" << FROM_HERE << ": in function 'main'" << std::endl;

		return EXIT_FAILURE;
	}

	sharedEventLoop->RunMainLoopUntilDone();

	return EXIT_SUCCESS;
}