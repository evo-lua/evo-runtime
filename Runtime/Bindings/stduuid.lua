local ffi = require("ffi")

local stduuid = {}

stduuid.cdefs = [[
// RFC UUIDs are always 36 characters (+ null terminator)
typedef char uuid_rfc_string_t[37] ;

struct static_stduuid_exports_table {
	bool (*uuid_create_v4)(uuid_rfc_string_t *result);
	bool (*uuid_create_mt19937)(uuid_rfc_string_t *result);
	bool (*uuid_create_v5)(const char* namespace_uuid_str, const char* name, uuid_rfc_string_t* result);
	bool (*uuid_create_system)(uuid_rfc_string_t *result);
};
]]

function stduuid.initialize()
	ffi.cdef(stduuid.cdefs)
end

function stduuid.version()
	-- Hardcoded because of laziness (may automate tag discovery later)
	return "1.2.3"
end

return stduuid
