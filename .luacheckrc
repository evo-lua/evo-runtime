std = "lua51"
max_line_length = false
exclude_files = {
	"luacheckrc",
	"deps/",
	"ninjabuild-*/",
}
ignore = {
	"142", -- setting undefined field of global (likely a nonstandard extension)
	"143", -- accessing undefined field of global (likely a nonstandard extension)
	"212", -- unused argument 'self'; not a problem and commonly used for colon notation
	"213", -- unused loop variable (kept for readability's sake)
}
globals = {
	-- assertions library
	"assertTrue",
	"assertFalse",
	"assertNil",
	"assertThrows",
	"assertDoesNotThrow",
	"assertFailure",
	"assertCallsFunction",
	"assertEqualStrings",
	"assertEqualNumbers",
	"assertApproximatelyEquals",
	"assertEqualTables",
	"assertEqualBooleans",
	"assertEqualPointers",
	"assertEqualBytes",
	"assertEquals",

	-- Global aliases
	"ALERT",
	"CRITICAL",
	"DEBUG",
	"EMERGENCY",
	"ERROR",
	"EVENT",
	"INFO",
	"NOTICE",
	"WARNING",
	"after",
	"before",
	"buffer",
	"cast",
	"cdef",
	"class",
	"classname",
	"define",
	"describe",
	"dump",
	"extend",
	"format",
	"implements",
	"instanceof",
	"it",
	"mixin",
	"new",
	"path",
	"printf",
	"sizeof",
	"typeof",

	-- API namespaces
	"C_CommandLine",
	"C_FileSystem",
	"C_ImageProcessing",
	"C_Runtime",
	"C_Timer",
	"C_WebView",
}
