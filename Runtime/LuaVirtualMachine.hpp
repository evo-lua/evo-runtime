#pragma once

#include <iostream>
#include <lua.hpp>

class LuaVirtualMachine {
	public:
		LuaVirtualMachine();
		~LuaVirtualMachine();

		bool DoFile(std::string filePath);
		bool DoString(std::string chunk, std::string chunkName);
		bool CompileChunk(std::string chunk, std::string chunkName);
		bool RunCompiledChunk();
		bool SetGlobalArgs(int argc, char* argv[]);
		bool CheckStack();

	private:
		lua_State* m_luaState;
		int m_onLuaErrorIndex;
		// Getting these offsets wrong will cause segfaults, so let's just track them and get it over with...
		int m_numExpectedArgsFromLuaMain;
		int m_relativeStackOffset;
};