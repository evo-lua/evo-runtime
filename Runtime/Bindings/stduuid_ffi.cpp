#include "macros.hpp"

#include <random>
#include <array>
#include <string>

// The platform-specific RNG APIs aren't enabled by default since they're non-standard
#define UUID_SYSTEM_GENERATOR
#include "uuid.h"
#undef UUID_SYSTEM_GENERATOR

#include "stduuid_ffi.hpp"

std::ranlux48_base create_basic_generator() {
	std::random_device random_number_generator;
	auto seed_data = std::array<int, 6> {};

	std::generate(std::begin(seed_data), std::end(seed_data), std::ref(random_number_generator));
	std::seed_seq random_byte_sequence(std::begin(seed_data), std::end(seed_data));

	return std::ranlux48_base(random_byte_sequence);
}

std::mt19937 create_mt19937_generator() {
	std::random_device random_number_generator;
	auto seed_data = std::array<int, std::mt19937::state_size> {};

	std::generate(std::begin(seed_data), std::end(seed_data), std::ref(random_number_generator));
	std::seed_seq random_byte_sequence(std::begin(seed_data), std::end(seed_data));

	return std::mt19937(random_byte_sequence);
}

// Static generators are kept around so that they don't need to be seeded for every UUID
static std::ranlux48_base low_quality_rng = create_basic_generator();
static std::mt19937 high_quality_rng = create_mt19937_generator();

bool uuid_create_v4(uuid_rfc_string_t* result) {
	uuids::basic_uuid_random_generator<std::ranlux48_base> gen(&low_quality_rng);

	uuids::uuid const id = gen();
	std::string str_id = uuids::to_string(id);

	std::memcpy(result, str_id.c_str(), str_id.size());
	(*result)[str_id.size()] = '\0';

	return true;
}

bool uuid_create_mt19937(uuid_rfc_string_t* result) {
	uuids::basic_uuid_random_generator<std::mt19937> gen(&high_quality_rng);

	uuids::uuid const id = gen();
	std::string str_id = uuids::to_string(id);

	std::memcpy(result, str_id.c_str(), str_id.size());
	(*result)[str_id.size()] = '\0';

	return true;
}

bool uuid_create_v5(const char* namespace_uuid_str, const char* name, uuid_rfc_string_t* result) {
	uuids::uuid namespace_uuid = uuids::uuid::from_string(namespace_uuid_str).value();
	uuids::uuid_name_generator gen(namespace_uuid);
	uuids::uuid const id = gen(name);

	std::string str_id = uuids::to_string(id);

	std::memcpy(result, str_id.c_str(), str_id.size());
	(*result)[str_id.size()] = '\0';

	return true;
}

bool uuid_create_system(uuid_rfc_string_t* result) {
	uuids::uuid const id = uuids::uuid_system_generator {}();
	std::string str_id = uuids::to_string(id);

	std::memcpy(result, str_id.c_str(), str_id.size());
	(*result)[str_id.size()] = '\0';

	return true;
}

namespace stduuid_ffi {

	#include "stduuid_exports_generated.h"

	std::string getTypeDefinitions() {
		return std::string(*Runtime_Bindings_stduuid_exports_h, Runtime_Bindings_stduuid_exports_h_len);
	}

	void* getExportsTable() {
		static struct static_stduuid_exports_table stduuid_exports_table;

		stduuid_exports_table.uuid_create_v4 = uuid_create_v4;
		stduuid_exports_table.uuid_create_mt19937 = uuid_create_mt19937;
		stduuid_exports_table.uuid_create_v5 = uuid_create_v5;
		stduuid_exports_table.uuid_create_system = uuid_create_system;

		return &stduuid_exports_table;
	}
}