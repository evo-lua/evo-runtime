struct static_runtime_exports_table {
	// Build configuration
	const char* (*runtime_version)(void);

	// REPL
	void (*runtime_repl_start)(void);
};