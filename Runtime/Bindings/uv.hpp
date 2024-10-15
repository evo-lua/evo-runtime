#include "lua.hpp"
#include <unordered_map>
#include <uv.h>
#include <cassert>

static std::unordered_map<uv_handle_t*, void*> foreignHandles;

extern "C" {

// TBD need extern for libuv?
static void detect_foreign_handles(uv_handle_t* handle, void* arg) { // TBD remove static?
	printf("Detected foreign uws handle %p with userdata %p\n", handle, handle->data);
	foreignHandles[handle] = handle->data;
}

#include "luv.h"

static void luv_walk_cb_noforeign(uv_handle_t* handle, void* arg) {
	assert(handle != NULL);
	assert(handle->data != NULL);

	lua_State* L = (lua_State*)arg;
	printf("Running luv_walk_cb_noforeign for handle with data: %p\n", handle->data);

	// lua_getglobal(L, "UWS_EVENT_LOOP"); // Retrieve the UWS loop pointer
	// void* usLoopPointer = lua_touserdata(L, -1);
	// assert(usLoopPointer != NULL);
	// lua_pop(L, 1); // Clean up the stack

	// Compare the usLoopPointer with handle's data to tag foreign handles
	// TBD just tag them by iterating once, this is probably needlessly wasteful
	auto iterator = foreignHandles.find(handle);
	if(iterator != foreignHandles.end()) {
		printf("Tagging foreign handle in luv_walk_cb_noforeign: %p -> %p\n", handle, handle->data);
		// foreignHandles[handle] = handle->data; // Store the foreign handle
		handle->data = LUVF_EXTERNAL_HANDLE; // NULL; // Mark it as foreign (or ignored) for luv
	}
}

static void luv_walk_cb_noforeign_done(uv_handle_t* handle, void* arg) {
	assert(handle != NULL);

	// Check if the handle was tagged as foreign in the previous walk
	auto iterator = foreignHandles.find(handle);
	if(iterator != foreignHandles.end()) {
		void* userdataPointer = iterator->second;
		printf("Restoring tagged foreign handle in luv_walk_cb_noforeign_done: %p -> %p\n", handle, userdataPointer);
		handle->data = userdataPointer; // Restore the handle data

		// Remove the handle from the map after restoring it
		// foreignHandles.erase(iterator);
	}
}

int luv_walk_noforeign(lua_State* L) {
	printf("luv_walk_noforeign called\n");

	// Clear the foreignHandles map to ensure it's empty before starting
	// foreignHandles.clear();

	// Perform the first walk to tag foreign handles
	uv_walk(luv_loop(L), luv_walk_cb_noforeign, L);

	// Call the original 'uv.walk' function from Lua
	lua_getglobal(L, "require");
	lua_pushstring(L, "uv");
	lua_call(L, 1, 1); // Load 'uv' module (assumes 1 return value on success)

	lua_getfield(L, -1, "__walk");
	lua_pushvalue(L, 1); // Push the function argument from Lua stack
	lua_call(L, 1, 0); // Call 'uv.walk', expecting no return values

	// Perform the second walk to restore foreign handles
	uv_walk(luv_loop(L), luv_walk_cb_noforeign_done, L);

	// Ensure the foreignHandles map is cleared after the operation
	// foreignHandles.clear();

	return 0;
}

int luaopen_luv_modified(lua_State* L) {
	int success = luaopen_luv(L);
	if(success != 1) {
		luaL_error(L, "Could not open luv");
	}

	// Backup the original 'walk' function
	lua_getfield(L, -1, "walk");
	lua_setfield(L, -2, "__walk");

	// Replace the 'walk' function with 'luv_walk_noforeign'
	lua_pushcfunction(L, luv_walk_noforeign);
	lua_setfield(L, -2, "walk");

	return success;
}
}
