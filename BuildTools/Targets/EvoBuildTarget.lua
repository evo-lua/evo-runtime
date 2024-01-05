local BuildTarget = require("BuildTools.BuildTarget")
local NinjaBuildTools = require("BuildTools.NinjaBuildTools")

local EvoBuildTarget = {
	OUTPUT_FILE_NAME = NinjaBuildTools.GetExecutableName("evo"),
	BUILD_DIR = NinjaBuildTools.DEFAULT_BUILD_DIRECTORY_NAME,
	GIT_VERSION_TAG = NinjaBuildTools.DiscoverGitVersionTag(),
	-- Can't easily discover sources or resolve paths with only Lua APIs. Listing them explicitly is probably safer anyway
	-- Note that ninja doesn't care about path separators and the mingw toolchain supports forward slashes; no \ required
	luaSources = {
		-- Integrated third-party code (no build system required)
		"deps/kikito/inspect.lua/inspect.lua",
		-- These modules may need some streamlining, so for now they're undocumented
		"BuildTools/NinjaBuildTools.lua",
		"BuildTools/NinjaFile.lua",
		-- Standard libraries
		"Runtime/evo.lua",
		"Runtime/API/C_CommandLine.lua",
		"Runtime/API/C_FileSystem.lua",
		"Runtime/API/C_ImageProcessing.lua",
		"Runtime/API/C_Runtime.lua",
		"Runtime/API/C_Timer.lua",
		"Runtime/API/C_WebView.lua",
		"Runtime/API/Networking/HttpServer.lua",
		"Runtime/API/Networking/WebSocketTestClient.lua",
		"Runtime/API/Networking/WebSocketServer.lua",
		"Runtime/Bindings/crypto.lua",
		"Runtime/Bindings/glfw.lua",
		"Runtime/Bindings/iconv.lua",
		"Runtime/Bindings/interop.lua",
		"Runtime/Bindings/rml.lua",
		"Runtime/Bindings/stbi.lua",
		"Runtime/Bindings/stduuid.lua",
		"Runtime/Bindings/uws.lua",
		"Runtime/Bindings/webgpu.lua",
		"Runtime/Bindings/webview.lua",
		"Runtime/Extensions/debugx.lua",
		"Runtime/Extensions/jsonx.lua",
		"Runtime/Extensions/stringx.lua",
		"Runtime/Extensions/tablex.lua",
		"Runtime/Libraries/assertions.lua",
		"Runtime/Libraries/bdd.lua",
		"Runtime/Libraries/console.lua",
		"Runtime/Libraries/etrace.lua",
		"Runtime/Libraries/path.lua",
		"Runtime/Libraries/transform.lua",
		"Runtime/Libraries/uuid.lua",
		"Runtime/Libraries/validation.lua",
		"Runtime/Libraries/vfs.lua",
		"Runtime/Libraries/v8.lua",
	},
	cppSources = {
		"Runtime/main.cpp",
		"Runtime/Bindings/crypto_argon2.cpp",
		"Runtime/Bindings/crypto_ffi.cpp",
		"Runtime/Bindings/glfw_ffi.cpp",
		"Runtime/Bindings/iconv_ffi.cpp",
		"Runtime/Bindings/interop_ffi.cpp",
		"Runtime/Bindings/lminiz.cpp",
		"Runtime/Bindings/RmlUi_Renderer_WebGPU.cpp",
		"Runtime/Bindings/rml_ffi.cpp",
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
		"deps/mikke89/RmlUi/Backends",
		"deps/mikke89/RmlUi/Include",
	},
	staticLibraries = {
		"libluajit.a",
		"libluv.a",
		"libuv.a",
		"libglfw3.a",
		"libminiz.a",
		"openssl.a",
		"libpcre2-8.a",
		"librapidjson.a",
		"libssl.a",
		"libcrypto.a",
		"libwgpu_native.a",
		"uSockets.a",
		"zlibstatic.a",
		"libRmlCore.a",
		"libfreetype.a",
	},
	sharedLibraries = {
		Windows = {
			"psapi",
			"user32",
			"advapi32",
			"iphlpapi",
			"userenv",
			"ws2_32",
			"gdi32",
			"crypt32",
			"shell32",
			"ole32",
			"version",
			"shlwapi",
			"dbghelp",
			"uuid",
			"bcrypt",
			"d3dcompiler",
			"ntdll",
			"iconv",
			"opengl32",
		},
		OSX = {
			"m",
			"dl",
			"iconv",
			"pthread",
			"Cocoa",
			"IOKit",
			"QuartzCore",
			"Metal",
			"WebKit",
		},
		Linux = {
			"m",
			"dl",
			"pthread",
			"uuid",
			"webkit2gtk-4.0",
			"gtk-3",
			"gdk-3",
			"z",
			"pangocairo-1.0",
			"pango-1.0",
			"harfbuzz",
			"atk-1.0",
			"cairo-gobject",
			"cairo",
			"gdk_pixbuf-2.0",
			"soup-2.4",
			"gmodule-2.0",
			"glib-2.0",
			"gio-2.0",
			"javascriptcoregtk-4.0",
			"gobject-2.0",
			"glib-2.0",
		},
	},
	staticallyLinkStandardLibraries = {
		Windows = true,
	},
}

return BuildTarget(EvoBuildTarget)
