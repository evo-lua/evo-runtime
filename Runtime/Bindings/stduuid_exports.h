// RFC UUIDs are always 36 characters (+ null terminator)
typedef char uuid_rfc_string_t[37];

struct static_stduuid_exports_table {
	bool (*uuid_create_v4)(uuid_rfc_string_t* result);
	bool (*uuid_create_mt19937)(uuid_rfc_string_t* result);
	bool (*uuid_create_v5)(const char* namespace_uuid_str, const char* name, uuid_rfc_string_t* result);
	bool (*uuid_create_system)(uuid_rfc_string_t* result);
};