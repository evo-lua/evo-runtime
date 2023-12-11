local BuildTarget = require("BuildTools.BuildTarget")
local NinjaBuildTools = require("BuildTools.NinjaBuildTools")

local EvoBuildTarget = {
	OUTPUT_FILE_NAME = NinjaBuildTools.GetStaticLibraryName("rapidjson"),
	BUILD_DIR = NinjaBuildTools.DEFAULT_BUILD_DIRECTORY_NAME,
	GIT_VERSION_TAG = NinjaBuildTools.DiscoverGitVersionTag(), -- TODO path?
	-- Can't easily discover sources or resolve paths with only Lua APIs. Listing them explicitly is probably safer anyway
	-- Note that ninja doesn't care about path separators and the mingw toolchain supports forward slashes; no \ required
	luaSources = {},
	cppSources = {
		"Runtime/main.cpp",
		"Runtime/Bindings/crypto_argon2.cpp",
		"Runtime/Bindings/crypto_ffi.cpp",
		"Runtime/Bindings/glfw_ffi.cpp",
		"Runtime/Bindings/iconv_ffi.cpp",
		"Runtime/Bindings/interop_ffi.cpp",
		"Runtime/Bindings/lminiz.cpp",
		"Runtime/Bindings/stbi_ffi.cpp",
		"Runtime/Bindings/stduuid_ffi.cpp",
		"Runtime/Bindings/uws_ffi.cpp",
		"Runtime/Bindings/webgpu_ffi.cpp",
		"Runtime/Bindings/webview_ffi.cpp",
		"Runtime/Bindings/lrexlib.cpp",
		"Runtime/Bindings/lzlib.cpp",
		"Runtime/Bindings/WebServer.cpp",
		"Runtime/LuaVirtualMachine.cpp",
	},
	includeDirectories = {
		NinjaBuildTools.DEFAULT_BUILD_DIRECTORY_NAME, -- For auto-generated headers (e.g., PCRE2)
		"Runtime",
		"Runtime/Bindings",
		"deps",
		"deps/eliemichel/glfw3webgpu",
		"deps/glfw/glfw/include",
		"deps/LuaJIT/LuaJIT/src",
		"deps/luvit/luv/src",
		"deps/luvit/luv/deps/libuv/include",
		"deps/mariusbancila/stduuid/include",
		"deps/nothings/stb",
		"deps/webview/webview",
		"deps/openssl/openssl/include",
		"deps/zhaog/lua-openssl/deps/auxiliar",
		"deps/zhaog/lua-openssl/src",
		"deps/brimworks/lua-zlib",
		"deps/uNetworking/uWebSockets/src",
		"deps/uNetworking/uWebSockets/uSockets/src",
		"deps/xpol/lua-rapidjson/src",
		"deps/xpol/lua-rapidjson/rapidjson/include",
	},
	staticLibraries = {
	},
	sharedLibraries = {
		Windows = {
		},
		OSX = {
		},
		Linux = {
		},
	},
	staticallyLinkStandardLibraries = {
	},
}

return BuildTarget(EvoBuildTarget)
