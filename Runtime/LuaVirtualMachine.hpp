#pragma once

#include <iostream>
#include <optional>
#include <lua.hpp>

// As per convention, any C function that creates a table with the library APIs and pushes it to the stack
typedef int (*luaopen_function)(lua_State* L);

class LuaVirtualMachine {
public:
	LuaVirtualMachine();
	~LuaVirtualMachine();

	bool LoadPackage(std::string packageName);
	bool LoadPackage(std::string packageName, std::optional<lua_CFunction> packageLoader);
	bool DoFile(std::string filePath);
	bool DoString(std::string chunk, std::string chunkName);
	bool CompileChunk(std::string chunk, std::string chunkName);
	bool RunCompiledChunk();
	bool SetGlobalArgs(int argc, char* argv[]);
	void BindStaticLibraryExports(std::string fieldName, void* staticExportsTable);
	void CreateGlobalNamespace(std::string name);
	void AssignGlobalVariable(std::string key, std::string value);
	void AssignGlobalVariable(std::string key, void* lightUserdataPointer);
	bool CheckStack();
	lua_State* GetState();

private:
	lua_State* m_luaState;
	int m_onLuaErrorIndex;
	// Getting these offsets wrong will cause segfaults, so let's just track them and get it over with...
	int m_numExpectedArgsFromLuaMain;
	int m_relativeStackOffset;

	static int emptyPackageLoader(lua_State* m_luaState) {
		lua_newtable(m_luaState);
		return 1;
	}
};