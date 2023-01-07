std = "lua51"
max_line_length = false
exclude_files = {
	"luacheckrc",
	"deps/",
}
ignore = {
	"143", -- accessing undefined field of global (likely a nonstandard extension)
	"212", -- unused argument 'self'; not a problem and commonly used for colon notation
	"213", -- unused loop variable (kept for readability's sake)
}
globals = {}
