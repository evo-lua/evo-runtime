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

int main(int argc, char* argv[]) {
	std::unique_ptr<LuaVirtualMachine> luaVM = std::make_unique<LuaVirtualMachine>();

	argv = uv_setup_args(argc, argv); // Required on Linux (see https://github.com/libuv/libuv/issues/2845)
	luaVM->SetGlobalArgs(argc, argv);

	// luv sets up its metatables when initialized; deferring this may break some internals (not sure why)
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

	runtime_ffi::assignLuaState(luaVM->GetState());
	rml_ffi::assignLuaState(luaVM->GetState());

	// A bit of a hack; Can't use uv_default_loop because luv maintains a separate "default" loop of its own
	uv_loop_t* loop = luv_loop(luaVM->GetState());
	auto uwsEventLoop = uws_ffi::assignEventLoop(loop);
	luaVM->AssignGlobalVariable("UWS_EVENT_LOOP", static_cast<void*>(uwsEventLoop));

	std::string mainChunk = "local evo = require('evo'); return evo.run()";
	std::string chunkName = "=(Lua entry point, at " FROM_HERE ")";

	int success = luaVM->DoString(mainChunk, chunkName);
	if(!success) {
		std::cerr << "\t" << FROM_HERE << ": in function 'main'" << std::endl;

		uws_ffi::unassignEventLoop(uwsEventLoop);
		return EXIT_FAILURE;
	}

	uv_run(loop, UV_RUN_DEFAULT);

	uws_ffi::unassignEventLoop(uwsEventLoop);
	return EXIT_SUCCESS;
}