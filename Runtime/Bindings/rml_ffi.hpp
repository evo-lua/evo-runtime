#pragma once

#include <RmlUi_Platform_GLFW.h>
#include <RmlUi_Renderer_WebGPU.hpp>

#include <webgpu.h>

typedef WGPUDevice wgpu_device_t;
typedef void* rml_context_t;
typedef void* rml_document_t;
typedef rml_geometry_info_t* rml_compiled_geometry_t;

struct static_rml_exports_table {
	const char* (*rml_version)(void);
	bool (*rml_initialise)(void);
	void (*rml_shutdown)(void);

	// GLFW integration
	SystemInterface_GLFW* (*rml_create_glfw_system_interface)(void);
	void (*rml_destroy_glfw_system_interface)(SystemInterface_GLFW* glfw_system_interface);
	void (*rml_set_system_interface)(SystemInterface_GLFW* glfw_system_interface);

	// WebGPU integration
	RenderInterface_WebGPU* (*rml_create_wgpu_render_interface)(wgpu_device_t existing_wgpu_device, deferred_event_queue_t queue);
	void (*rml_destroy_wgpu_render_interface)(RenderInterface_WebGPU* wgpu_render_interface);
	void (*rml_set_render_interface)(RenderInterface_WebGPU* wgpu_render_interface);
	void (*rml_release_compiled_geometry)(rml_compiled_geometry_t geometry);

	// Rml::Document APIs
	void (*rml_document_show)(rml_document_t document);

	// Rml::Context APIs
	rml_context_t (*rml_context_create)(const char* name, uint16_t width, uint16_t height);
	void (*rml_context_update)(rml_context_t context_pointer);
	void (*rml_context_render)(rml_context_t context_pointer);
	void (*rml_context_remove)(const char* name);
	rml_document_t (*rml_context_load_document)(rml_context_t context_pointer, const char* file_path);

	// Font management APIs
	bool (*rml_load_font_face)(const char* file_path, bool is_fallback_face);
};

namespace rml_ffi {
	void* getExportsTable();
}
