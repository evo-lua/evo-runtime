print("Hello world!")

-- Depending on how the script is run, the order of args will be different (unless corrected)
assert(arg[1] == "hi")
assert(arg[2] == nil)
require("deps.gpu")

local ffi = require("ffi")

ffi.cdef[[
void hello();
]]


local uv = require("uv")
local tmpPath =uv.os_tmpdir()
printf("Temporary path created for DLL/SO extraction: %s", tmpPath)
-- Extract file from VFS
local libhello = ffi.load("libhello.so") -- pass tmp path

-- put this in vfs library as vfs.load, if isZipApp then replace ffi.load - OR
-- alternatively, let vfs.load fall back to ffi.load if not a zip app. Then users may use vfs.load or ffi.load as desired (vfs > disk vs disk-only load semantics)

libhello.hello()
