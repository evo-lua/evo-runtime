return {
	name = "AppendFile",
	description = "Opens the given `filePath` in append mode and writes `contents` to the end of the file.",
	isBlocking = true,
	since = "v0.0.1",
	parameters = {
		{
			name = "filePath",
			type = "string",
		},
		{
			name = "contents",
			type = "string",
		},
	},
	returns = {
		{
			name = "success",
			type = "boolean",
		},
	},
	sourceLocation = "TODO",
	examples = {
		-- TODO links
		-- TBD test cases also?
	},
}
