#include "cpp_ffi.hpp"

namespace cpp_ffi {
	// Workaround: The signature of bid_width was changed in the standard, which can break older compilers
	int std_bit_width(size_t n) {
		return static_cast<int>(std::bit_width(static_cast<size_t>(n)));
	}

	void* getExportsTable() {
		static struct static_cpp_exports_table exports_table;

		exports_table.bit_ceil = &std::bit_ceil;
		exports_table.bit_floor = &std::bit_floor;
		exports_table.bit_width = &std_bit_width;
		exports_table.has_single_bit = &std::has_single_bit;

		return &exports_table;
	}
}