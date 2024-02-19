#include "cpp_ffi.hpp"

namespace cpp_ffi {
	void* getExportsTable() {
		static struct static_cpp_exports_table exports_table;

		exports_table.bit_ceil = &std::bit_ceil;
		exports_table.bit_floor = &std::bit_floor;
		exports_table.bit_width = &std::bit_width;
		exports_table.has_single_bit = &std::has_single_bit;

		return &exports_table;
	}
}