#include "lua.hpp"

static std::unordered_map<uv_handle_t*, void*> foreignHandles;

extern "C" {
#include "uv.h"
#include "luv.h"

static void luv_walk_cb_noforeign(uv_handle_t* handle, void* arg) {
	assert(handle != NULL);
	assert(handle->data != NULL);

	lua_State* L = (lua_State*)arg;
	printf("Running luv_walk_cb_noforeign for handle with data: %p\n", handle->data);

	lua_getglobal(L, "UWS_EVENT_LOOP"); // TODO use uws.usLoopPointer, or just pass in C++ directly (privately)
	void* usLoopPointer = lua_touserdata(L, -1);
	assert(usLoopPointer != NULL);

	if(usLoopPointer == handle->data) { // questionable, need a better solution
		printf("Tagging foreign handle in luv_walk_cb_noforeign: %p -> %p\n", handle, handle->data);
		// foreignHandles.insert(handle, handle->data); // TBD insert vs emplace vs emplace_hint, tbd can skip if data is always loop (impl detail?)
		foreignHandles[handle] = handle->data;
		handle->data = NULL; // TODO LUV_FOREIGN_HANDLE or luv_ignore_handle() / luv_unignore_handle()
	}

}

static void luv_walk_cb_noforeign_done(uv_handle_t* handle, void* arg) {
	assert(handle != NULL);
	assert(handle->data != NULL);

	// lua_State* L = (lua_State*)arg;

	printf("Running luv_walk_cb_noforeign_done for handle with data: %p\n", handle->data);

	auto iterator = foreignHandles.find(handle);
	if(iterator != foreignHandles.end()) {
		// void* userdataPointer = iterator->second();
		void* userdataPointer = foreignHandles[handle];
		printf("Restoring tagged foreign handle in luv_walk_cb_noforeign_done: %p -> %p\n", handle,userdataPointer);
		handle->data = foreignHandles[handle];
	}
}

int luv_walk_noforeign(lua_State* L) { // TODO review use of static and extern C everywhere
	printf("luv_walk_noforeign called\n");
	luaL_checktype(L, 1, LUA_TFUNCTION);
	
	// TODO clear map or just assert it is empty??
	uv_walk(luv_loop(L), luv_walk_cb_noforeign, L); // save_foreign_userdata

	// local uv = require("uv").walk(<function arg 1>)
	lua_getglobal(L, "require");
	lua_pushstring(L, "uv");
	lua_call(L, 1, 1); // TBD should be 1 return always?
	lua_getfield(L, -1, "walk");
	lua_call(L, 1, 1); // TBD should be 1 return always?
	
	uv_walk(luv_loop(L), luv_walk_cb_noforeign_done, L); // restore_foreign_userdata
	// TODO call the original function
	// TODO clear map?

	return 0;
}

int luaopen_luv_modified(lua_State* L) {
	int success = luaopen_luv(L);
	if(success != 1) {
		luaL_error(L, "Could not open luv");
	}

	// TODO save the original walk function to call later

	lua_getfield(L, -1, "walk");
	lua_setfield(L, -2, "__walk");

	lua_pushcfunction(L, luv_walk_noforeign);
	lua_setfield(L, -2, "walk");

	return success;
}
}