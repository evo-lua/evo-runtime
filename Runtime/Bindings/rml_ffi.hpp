#pragma once

#include <RmlUi/Lua.h>
#include <RmlUi_Platform_GLFW.h>
#include <RmlUi_Renderer_WebGPU.hpp>

#include <webgpu.h>

#include <string>

typedef WGPUDevice wgpu_device_t;
typedef rml_geometry_info_t* rml_compiled_geometry_t;
typedef GLFWwindow* glfw_window_t;

#include "rml_exports.h"

namespace rml_ffi {
	void assignLuaState(lua_State* L);
	lua_State* getAssignedLuaState();
	void* getExportsTable();
}
