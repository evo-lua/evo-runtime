#define RMLUI_STATIC_LIB

#include <RmlUi/Core.h>
#include <RmlUi/Lua.h>
#include <RmlUi_Platform_GLFW.h>
#include <RmlUi_Renderer_WebGPU.hpp>

// Workaround for RMLUI_STATIC_LIB not being propagated on Windows (revisit later, maybe)
#include <RmlUi_Platform_GLFW.cpp>

#include "interop_ffi.hpp"
#include "macros.hpp"
#include "rml_ffi.hpp"

const char* rml_version() {
	static std::string versionString = Rml::GetVersion();
	return versionString.c_str();
}

bool rml_initialise() {
	bool success = Rml::Initialise();
	lua_State* assignedLuaState = rml_ffi::getAssignedLuaState();

	// RML overwrites the builtin print function, which is arguably undesirable in this context
	lua_getglobal(assignedLuaState, "print");
	lua_setfield(assignedLuaState, LUA_REGISTRYINDEX, "original_print");

	Rml::Lua::Initialise(assignedLuaState);

	lua_getfield(assignedLuaState, LUA_REGISTRYINDEX, "original_print");
	lua_setglobal(assignedLuaState, "print");

	lua_pushnil(assignedLuaState);
	lua_setfield(assignedLuaState, LUA_REGISTRYINDEX, "original_print");

	return success;
}

void rml_shutdown() {
	Rml::Shutdown();
}

SystemInterface_GLFW* rml_create_glfw_system_interface() {
	return new SystemInterface_GLFW;
}

void rml_destroy_glfw_system_interface(SystemInterface_GLFW* glfw_system_interface) {
	delete glfw_system_interface;
}

void rml_set_system_interface(SystemInterface_GLFW* glfw_system_interface) {
	if(!glfw_system_interface) return;
	Rml::SetSystemInterface(glfw_system_interface);
}

RenderInterface_WebGPU* rml_create_wgpu_render_interface(WGPUDevice wgpuDevice, deferred_event_queue_t queue) {
	if(!wgpuDevice) return nullptr;
	if(!queue) return nullptr;

	return new RenderInterface_WebGPU(wgpuDevice, queue);
}

void rml_destroy_wgpu_render_interface(RenderInterface_WebGPU* wgpu_render_interface) {
	delete wgpu_render_interface;
}

void rml_set_render_interface(RenderInterface_WebGPU* wgpu_render_interface) {
	if(!wgpu_render_interface) return;

	Rml::SetRenderInterface(wgpu_render_interface);
}

bool rml_load_font_face(const char* file_path, bool is_fallback_face) {
	if(!Rml::GetFontEngineInterface()) return false; // Forgot to call initialise?
	if(!file_path) return false;

	return Rml::LoadFontFace(file_path, is_fallback_face);
}

rml_context_t rml_context_create(const char* name, uint16_t width, uint16_t height) {
	if(!name) return nullptr;

	Rml::Context* context = Rml::CreateContext(name, Rml::Vector2i(width, height));
	return static_cast<rml_context_t>(context);
}

rml_document_t rml_context_load_document(rml_context_t context_pointer, const char* file_path) {
	if(!context_pointer) return nullptr;
	if(!file_path) return nullptr;

	Rml::Context* context = static_cast<Rml::Context*>(context_pointer);
	Rml::ElementDocument* document = context->LoadDocument(file_path);
	return static_cast<rml_document_t>(document);
}

void rml_document_show(rml_document_t document) {
	if(!document) return;

	static_cast<Rml::ElementDocument*>(document)->Show();
}

void rml_context_update(rml_context_t context_pointer) {
	if(!context_pointer) return;

	Rml::Context* context = static_cast<Rml::Context*>(context_pointer);
	context->Update();
}

void rml_context_render(rml_context_t context_pointer) {
	if(!context_pointer) return;

	Rml::Context* context = static_cast<Rml::Context*>(context_pointer);
	context->Render();
}

void rml_context_remove(const char* name) {
	if(!name) return;
	Rml::RemoveContext(name);
}

void rml_release_compiled_geometry(rml_geometry_info_t* geometry) {
	delete geometry;
}

bool rml_process_key_callback(rml_context_t context_pointer, int key, int action, int mods) {
	if(!context_pointer) return true;

	auto context = static_cast<Rml::Context*>(context_pointer);
	return RmlGLFW::ProcessKeyCallback(context, key, action, mods);
}

bool rml_process_char_callback(rml_context_t context_pointer, unsigned int codepoint) {
	if(!context_pointer) return true;

	auto context = static_cast<Rml::Context*>(context_pointer);
	return RmlGLFW::ProcessCharCallback(context, codepoint);
}

bool rml_process_cursor_enter_callback(rml_context_t context_pointer, int entered) {
	if(!context_pointer) return true;

	auto context = static_cast<Rml::Context*>(context_pointer);
	return RmlGLFW::ProcessCursorEnterCallback(context, entered);
}

bool rml_process_cursor_pos_callback(rml_context_t context_pointer, glfw_window_t window, double xpos, double ypos, int mods) {
	if(!context_pointer) return true;

	auto context = static_cast<Rml::Context*>(context_pointer);
	return RmlGLFW::ProcessCursorPosCallback(context, window, xpos, ypos, mods);
}

bool rml_process_mouse_button_callback(rml_context_t context_pointer, int button, int action, int mods) {
	if(!context_pointer) return true;

	auto context = static_cast<Rml::Context*>(context_pointer);
	return RmlGLFW::ProcessMouseButtonCallback(context, button, action, mods);
}

bool rml_process_scroll_callback(rml_context_t context_pointer, double yoffset, int mods) {
	if(!context_pointer) return true;

	auto context = static_cast<Rml::Context*>(context_pointer);
	return RmlGLFW::ProcessScrollCallback(context, yoffset, mods);
}

void rml_process_framebuffer_size_callback(rml_context_t context_pointer, int width, int height) {
	if(!context_pointer) return;

	auto context = static_cast<Rml::Context*>(context_pointer);
	RmlGLFW::ProcessFramebufferSizeCallback(context, width, height);
}

void rml_process_content_scale_callback(rml_context_t context_pointer, float xscale) {
	if(!context_pointer) return;

	auto context = static_cast<Rml::Context*>(context_pointer);
	RmlGLFW::ProcessContentScaleCallback(context, xscale);
}

namespace rml_ffi {
	lua_State* assignedLuaState;
	void assignLuaState(lua_State* L) {
		assignedLuaState = L;
	}

	lua_State* getAssignedLuaState() {
		return rml_ffi::assignedLuaState;
	}

	void* getExportsTable() {
		static struct static_rml_exports_table exports_table;

		exports_table.rml_version = &rml_version;
		exports_table.rml_initialise = &rml_initialise;
		exports_table.rml_shutdown = &rml_shutdown;
		exports_table.rml_create_glfw_system_interface = &rml_create_glfw_system_interface;
		exports_table.rml_destroy_glfw_system_interface = &rml_destroy_glfw_system_interface;
		exports_table.rml_create_wgpu_render_interface = &rml_create_wgpu_render_interface;
		exports_table.rml_destroy_wgpu_render_interface = &rml_destroy_wgpu_render_interface;
		exports_table.rml_release_compiled_geometry = &rml_release_compiled_geometry;
		exports_table.rml_set_system_interface = &rml_set_system_interface;
		exports_table.rml_set_render_interface = &rml_set_render_interface;
		exports_table.rml_context_create = &rml_context_create;
		exports_table.rml_context_load_document = &rml_context_load_document;
		exports_table.rml_document_show = &rml_document_show;
		exports_table.rml_context_update = &rml_context_update;
		exports_table.rml_context_render = &rml_context_render;
		exports_table.rml_context_remove = &rml_context_remove;
		exports_table.rml_load_font_face = &rml_load_font_face;
		exports_table.rml_process_key_callback = &rml_process_key_callback;
		exports_table.rml_process_char_callback = &rml_process_char_callback;
		exports_table.rml_process_cursor_enter_callback = &rml_process_cursor_enter_callback;
		exports_table.rml_process_cursor_pos_callback = &rml_process_cursor_pos_callback;
		exports_table.rml_process_mouse_button_callback = &rml_process_mouse_button_callback;
		exports_table.rml_process_scroll_callback = &rml_process_scroll_callback;
		exports_table.rml_process_framebuffer_size_callback = &rml_process_framebuffer_size_callback;
		exports_table.rml_process_content_scale_callback = &rml_process_content_scale_callback;

		return &exports_table;
	}

}