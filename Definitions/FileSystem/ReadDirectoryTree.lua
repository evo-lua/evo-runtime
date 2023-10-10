return {
	name = "ReadDirectoryTree",
	description = "TODO", -- TBD what about admonitions/links/markdown/html? just store as raw text? this might get messy...
	isBlocking = true,
	since = "v0.0.4", -- or availableSince (more typing...)
	parameters = {
		{
			name = "directoryPath",
			type = "string",
		},
	},
	returns = {
		{
			name = "directoryContents",
			type = "table",
		},
	},
	types = {
		-- dictionary, struct, array, enum / may want to link this in instead?
	}
	sourceLocation = "TODO",
	examples = {
		-- TODO links
		-- TBD test cases also?
	},
}
