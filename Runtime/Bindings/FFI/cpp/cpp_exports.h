struct static_cpp_exports_table {
	// Numerics library
	size_t (*bit_ceil)(size_t n);
	size_t (*bit_floor)(size_t n);
	int (*bit_width)(size_t n);
	bool (*has_single_bit)(size_t n);
};