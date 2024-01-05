local ffi = require("ffi")

local tonumber = tonumber
local format = string.format

local rml = {}

rml.cdefs = [[
	typedef void* rml_context_t;
	typedef void* rml_document_t;

struct static_rml_exports_table {
	const char* (*rml_version)(void);
	bool (*rml_initialise)(void);
	void (*rml_shutdown)(void);

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

]]

function rml.initialize()
	ffi.cdef(rml.cdefs)
end

function rml.version()
	local cStringPointer = rml.bindings.rml_version()
	local versionString = ffi.string(cStringPointer)

	local versionMajor, versionMinor, versionPatch = versionString:match("(%d+)%.(%d+)%.*(%d*)")
	versionPatch = versionPatch ~= "" and versionPatch or "0"

	local semanticVersionString =
		format("%d.%d.%d", tonumber(versionMajor), tonumber(versionMinor), tonumber(versionPatch))
	return semanticVersionString
end

return rml
