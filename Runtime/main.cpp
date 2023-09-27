extern "C" {
#include "luv.h"
#include "lminiz.hpp"
#include "lrexlib.hpp"
#include "lzlib.hpp"
#include "openssl.h"
}

#include "rapidjson.hpp"

#include "evo.hpp"
#include "macros.hpp"
#include "glfw_ffi.hpp"
#include "iconv_ffi.hpp"
#include "interop_ffi.hpp"
#include "stbi_ffi.hpp"
#include "stduuid_ffi.hpp"
#include "uws_ffi.hpp"
#include "webgpu_ffi.hpp"
#include "webview_ffi.hpp"

#include "LuaVirtualMachine.hpp"

int main(int argc, char* argv[]) {
	LuaVirtualMachine* luaVM = new LuaVirtualMachine();

	argv = uv_setup_args(argc, argv); // Required on Linux (see https://github.com/libuv/libuv/issues/2845)
	luaVM->SetGlobalArgs(argc, argv);

	// luv sets up its metatables when initialized; deferring this may break some internals (not sure why)
	luaVM->PreloadPackage("uv", luaopen_luv);
	luaVM->PreloadPackage("miniz", luaopen_miniz);
	luaVM->PreloadPackage("openssl", luaopen_openssl);
	luaVM->PreloadPackage("regex", luaopen_rex_pcre2);
	luaVM->PreloadPackage("json", luaopen_rapidjson_modified);
	luaVM->PreloadPackage("zlib", luaopen_zlib);

	// The embedded libraries are statically linked in, so we require some glue code to access them via FFI
	luaVM->BindStaticLibraryExports("glfw", glfw_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("iconv", iconv_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("interop", interop_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("webview", webview_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("uws", uws_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("stbi", stbi_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("stduuid", stduuid_ffi::getExportsTable());
	luaVM->BindStaticLibraryExports("webgpu", webgpu_ffi::getExportsTable());

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
		std::cerr << "\t" << FROM_HERE << ": in function 'main'" << std::endl;
		return EXIT_FAILURE;
	}

	uv_run(loop, UV_RUN_DEFAULT);

	return EXIT_SUCCESS;
}