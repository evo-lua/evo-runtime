#include <cstring>
#include <iostream>
#include <optional>

#include "macros.hpp"

#include "LuaVirtualMachine.hpp"

int onLuaError(lua_State* m_luaState) {
	lua_pushvalue(m_luaState, LUA_GLOBALSINDEX);

	lua_getfield(m_luaState, -1, "debug");
	lua_remove(m_luaState, -2);

	lua_getfield(m_luaState, -1, "traceback");
	lua_pushvalue(m_luaState, 1);

	lua_pushinteger(m_luaState, 2);
	lua_call(m_luaState, 2, 1);

	return EXIT_FAILURE; // It's an error, after all
}

LuaVirtualMachine::LuaVirtualMachine() {
	m_relativeStackOffset = 0;

	// Standard Lua module convention: Return a single table with the module's exports
	m_numExpectedArgsFromLuaMain = 1;

	m_luaState = luaL_newstate();
	luaL_openlibs(m_luaState);

	// No need to modify the stack offset since this will never be popped
	lua_pushcfunction(m_luaState, onLuaError);
	m_onLuaErrorIndex = lua_gettop(m_luaState);
	this->CheckStack();
}

LuaVirtualMachine::~LuaVirtualMachine() {
	lua_close(m_luaState);
}

bool LuaVirtualMachine::LoadPackage(std::string packageName) {
	return LoadPackage(packageName, std::nullopt);
}

bool LuaVirtualMachine::LoadPackage(std::string packageName, std::optional<lua_CFunction> packageLoader) {
	lua_CFunction loader = packageLoader.value_or(emptyPackageLoader);

	lua_getglobal(m_luaState, "package");
	lua_getfield(m_luaState, -1, "loaded");

	lua_pushcfunction(m_luaState, loader);
	lua_call(m_luaState, 0, 1);
	lua_setfield(m_luaState, -2, packageName.c_str());

	lua_remove(m_luaState, -1);

	return true;
}

bool LuaVirtualMachine::DoFile(std::string filePath) {
	int status = luaL_dofile(m_luaState, filePath.c_str());
	if(status != LUA_OK) {
		std::cerr << "Error executing script: " << lua_tostring(m_luaState, -1) << std::endl;
		return false;
	}
	return this->CheckStack();
}

bool LuaVirtualMachine::DoString(std::string chunk, std::string chunkName) {
	this->CompileChunk(chunk, chunkName);
	int success = this->RunCompiledChunk();

	if(!success) {
		std::cerr << "\t" << FROM_HERE << ": in function 'DoString'"
				  << std::endl;
		return false;
	}

	return this->CheckStack();
}

bool LuaVirtualMachine::CompileChunk(std::string chunk, std::string chunkName) {
	const char* entry_point = chunk.c_str();

	int success = luaL_loadbuffer(m_luaState, entry_point, strlen(entry_point), chunkName.c_str());
	if(success != LUA_OK) {
		std::cerr << "Failed to compile chunk: " << lua_tostring(m_luaState, -1) << std::endl;
		return false;
	}

	m_relativeStackOffset++;
	return true;
}

bool LuaVirtualMachine::RunCompiledChunk() {
	if(lua_pcall(m_luaState, 0, m_numExpectedArgsFromLuaMain, m_onLuaErrorIndex)) {
		fprintf(stderr, "%s\n", lua_tostring(m_luaState, -1));
		std::cerr << "\t[C]: in function 'lua_pcall'" << std::endl;
		std::cerr << "\t" << FROM_HERE << ": in function 'RunCompiledChunk'" << std::endl;
		return false;
	}
	m_relativeStackOffset--; // Lua's pcall removes the compiled chunk

	return this->CheckStack();
}

bool LuaVirtualMachine::SetGlobalArgs(int argc, char* argv[]) {
	lua_createtable(m_luaState, argc, 0);
	m_relativeStackOffset++;

	for(int index = 1; index < argc + 1; index++) {
		// Skip the interpreter name because that's what PUC and LuaJIT do
		lua_pushstring(m_luaState, argv[index]);
		lua_rawseti(m_luaState, -2, index - 1);
	}

	lua_setglobal(m_luaState, "arg");
	m_relativeStackOffset--;

	return true; // Can this even fail? If so, the smoke tests should catch it anyway...
}

void LuaVirtualMachine::BindStaticLibraryExports(const std::string fieldName, void* staticExportsTable) {
	lua_getglobal(m_luaState, "package");
	lua_getfield(m_luaState, -1, "loaded");
	lua_getfield(m_luaState, -1, "bindings");

	if(lua_istable(m_luaState, -1)) {
		lua_pushlightuserdata(m_luaState, staticExportsTable);
		lua_setfield(m_luaState, -2, fieldName.c_str());
	}

	lua_pop(m_luaState, 3);
}

void LuaVirtualMachine::CreateGlobalNamespace(std::string name) {
	lua_newtable(m_luaState);
	lua_setglobal(m_luaState, name.c_str());
}

void LuaVirtualMachine::AssignGlobalVariable(std::string key, std::string value) {
	lua_pushstring(m_luaState, value.c_str());
	lua_setglobal(m_luaState, key.c_str());
}

void LuaVirtualMachine::AssignGlobalVariable(std::string key, void* lightUserdataPointer) {
	lua_pushlightuserdata(m_luaState, lightUserdataPointer);
	lua_setglobal(m_luaState, key.c_str());
}

bool LuaVirtualMachine::CheckStack() {
	// The most basic of checks, to make sure all symmetrical PUSH/POP operations are in alignment...
	if(m_relativeStackOffset != 0) {
		std::cerr << "m_relativeStackOffset should be zero, but is " << m_relativeStackOffset << " (LuaVirtualMachine stack may be corrupted?)" << std::endl;
		return false;
	}

	return true;
}

lua_State* LuaVirtualMachine::GetState() {
	return m_luaState;
}