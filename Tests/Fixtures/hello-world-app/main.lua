print("Hello world!")

-- Depending on how the script is run, the order of args will be different (unless corrected)
assert(arg[1] == "hi")
assert(arg[2] == nil)

-- Files that exist only in the VFS should always be loadable
local success, searchable = pcall(require, "searchable")
if success then -- Will only be found when this script is started from a LUAZIP app
	assert(searchable.checksum == 42)

	-- Files that exist in the VFS and on disk should be loaded from the VFS (security concern)
	local conflicting = require("conflicting")
	assert(conflicting.checksum == 12345)
end
