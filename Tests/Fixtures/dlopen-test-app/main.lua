local assertions = require("assertions")
local ffi = require("ffi")
local uv = require("uv")
local vfs = require("vfs")
local zlibStatic = require("zlib")

local assertEquals = assertions.assertEquals
local assertTrue = assertions.assertTrue

-- REMINDER: This part is copy/pasted from vfs-dlopen-zlib test (remove it later)
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

-- End of copy/pasted part
local zipApp = vfs.cachedAppBundles[uv.exepath()]
local zlibShared = assert(vfs.dlopen(zipApp, "zlib.so"))
local versionString = ffi.string(zlibShared.zlibVersion())

local zlibVersionMajor, zlibVersionMinor, zlibVersionPatch = zlibStatic.version()
local semanticZlibVersionString = format("%d.%d.%d", zlibVersionMajor, zlibVersionMinor, zlibVersionPatch or 0)

printf("Shared ZLIB version: %s", versionString)
printf("Static ZLIB version: %s", semanticZlibVersionString)
assertEquals(versionString, semanticZlibVersionString)
