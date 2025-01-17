local assertions = require("assertions")
local evo = require("evo")
local ffi = require("ffi")

local assertEquals = assertions.assertEquals
local assertFalse = assertions.assertFalse
local assertTrue = assertions.assertTrue

-- REMINDER: This part is copy/pasted into the actual test app (remove it later)
local testAppDirectory = path.join("Tests", "Fixtures", "dlopen-test-app")
-- If zlib hasn't been built, the test won't work (unfortunate, but acceptable for now)
local sharedLibraryExtension = (ffi.os == "Windows" and "dll" or "so")
local sharedLibraryPath = path.join(testAppDirectory, "zlib." .. sharedLibraryExtension)
assertTrue(C_FileSystem.Exists(sharedLibraryPath))

-- Basic sanity check: Let's first make sure that the shared object can be loaded at all
-- Note: The defined symbols must not clash in case FFI bindings for zlib also exist
local cdefs = [[
	const char* zlibVersion(void);
]] -- If these symbols are already part of the zlib bindings, can probably remove this

ffi.cdef(cdefs)
local sharedLibrary = ffi.load(sharedLibraryPath)
assertEquals(type(sharedLibrary), "userdata")
local ffiVersion = sharedLibrary.zlibVersion()
assertEquals(type(ffiVersion), "cdata")
local ffiVersionString = ffi.string(ffiVersion)
assertEquals(type(ffiVersionString), "string")

-- Now, a new LUAZIP app is needed since finalized miniz archives can't be diff-patched ...
-- This should probably be a separate library function in the vfs module, but right now it isn't
evo.buildZipApp("build", { testAppDirectory })
assertTrue(C_FileSystem.Exists("dlopen-test-app"))
assertTrue(C_FileSystem.Exists("dlopen-test-app.zip"))

-- Running the test with os.execute should be enough here as it mimicks real apps
local EXIT_SUCCESS = 0
local status, terminationReason, exitCode = os.execute("./dlopen-test-app")
assertTrue(status)
assertEquals(terminationReason, "exit")
assertEquals(exitCode, EXIT_SUCCESS)

-- Cleanup: Ideally this would be automatically handled by the interpreter CLI
C_FileSystem.Delete("dlopen-test-app")
C_FileSystem.Delete("dlopen-test-app.zip")
assertFalse(C_FileSystem.Exists("dlopen-test-app"))
assertFalse(C_FileSystem.Exists("dlopen-test-app.zip"))
