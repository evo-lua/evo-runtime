extern "C" {
#include "luv.h"
}

#include "evo.hpp"
#include "macros.hpp"

#include "LuaVirtualMachine.hpp"

int main(int argc, char* argv[]) {
	LuaVirtualMachine* luaVM = new LuaVirtualMachine();

	luaVM->SetGlobalArgs(argc, argv);

	// luv sets up its metatables when initialized; deferring this may break some internals (not sure why)
	luaVM->PreloadPackage("uv", luaopen_luv);

	std::string mainChunk = "local evo = require('evo'); return evo.run()";
	std::string chunkName = "=(Lua entry point, at " FROM_HERE ")";

	int success = luaVM->DoString(mainChunk, chunkName);
	if(!success) {
		PrintRuntimeError("Failed to require evo.lua", "Could not load embedded bytecode object", "Please report this problem on GitHub", FROM_HERE);
		return EXIT_FAILURE;
	}

	return EXIT_SUCCESS;
}