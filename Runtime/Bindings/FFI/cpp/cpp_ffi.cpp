#include "cpp_ffi.hpp"

namespace cpp_ffi {
	// Workaround: The signature of bid_width was changed in the standard, which can break older compilers
	int std_bit_width(size_t n) {
		return static_cast<int>(std::bit_width(static_cast<size_t>(n)));
	}

	void* getExportsTable() {
		static struct static_cpp_exports_table exports = {
			.bit_ceil = &std::bit_ceil,
			.bit_floor = &std::bit_floor,
			.bit_width = &std_bit_width,
			.has_single_bit = &std::has_single_bit,
		};

		return &exports;
	}
}