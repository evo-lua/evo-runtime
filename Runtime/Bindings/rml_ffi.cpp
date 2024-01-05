#define MATRIX_ROW_MAJOR
#define RMLUI_STATIC_LIB
#include <RmlUi/Core.h>

#include "interop_ffi.hpp"
#include "rml_ffi.hpp"

const char* rml_version() {
	static std::string versionString = Rml::GetVersion();
	return versionString.c_str();
}

bool rml_initialise() {
	return Rml::Initialise();
}

void rml_shutdown() {
	Rml::Shutdown();
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

namespace rml_ffi {

	void* getExportsTable() {
		static struct static_rml_exports_table exports_table;

		exports_table.rml_version = &rml_version;
		exports_table.rml_initialise = &rml_initialise;
		exports_table.rml_shutdown = &rml_shutdown;
		exports_table.rml_context_create = &rml_context_create;
		exports_table.rml_context_load_document = &rml_context_load_document;
		exports_table.rml_document_show = &rml_document_show;
		exports_table.rml_context_update = &rml_context_update;
		exports_table.rml_context_render = &rml_context_render;
		exports_table.rml_context_remove = &rml_context_remove;
		exports_table.rml_load_font_face = &rml_load_font_face;

		return &exports_table;
	}

}