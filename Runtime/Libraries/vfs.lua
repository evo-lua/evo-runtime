local ffi = require("ffi")
local miniz = require("miniz")
local validation = require("validation")

local ffi_cast = ffi.cast
local ffi_sizeof = ffi.sizeof
local ffi_string = ffi.string

local loadstring = loadstring
local tonumber = tonumber

local vfs = {
	LUAZIP_MAGIC_VALUE = "LUAZIP",
	cdefs = [[
		#pragma pack(push, 0)
		typedef struct {
			char magicValue[6];
			uint8_t versionMajor;
			uint8_t versionMinor;
			size_t executableSize;
			size_t archiveSize;
		} lua_zip_signature_t;
		#pragma pack(pop)
	]],
}

function vfs.decode(fileContents) -- TBD vfs.create?
	validation.validateString(fileContents, "fileContents")

	if #fileContents < ffi_sizeof("lua_zip_signature_t") then
		return nil, "Failed to decode LUAZIP buffer (input size is too small)"
	end

	local trailingBytes = fileContents:sub(-ffi_sizeof("lua_zip_signature_t"))
	local assumedSignature = ffi_cast("lua_zip_signature_t*", trailingBytes)
	local assumedHeader = ffi_string(assumedSignature.magicValue, ffi_sizeof(assumedSignature.magicValue))
	local hasMagicHeader = (assumedHeader == vfs.LUAZIP_MAGIC_VALUE)

	if not hasMagicHeader then
		return nil, "Failed to decode LUAZIP buffer (magic value is missing)"
	end

	local zipApp = {
		signature = {
			magicValue = assumedHeader,
			versionMajor = tonumber(assumedSignature.versionMajor),
			versionMinor = tonumber(assumedSignature.versionMinor),
			executableSize = tonumber(assumedSignature.executableSize),
			archiveSize = tonumber(assumedSignature.archiveSize),
		},
	}

	local executableStartOffset = 1
	local executableEndOffset = zipApp.signature.executableSize
	zipApp.executable = fileContents:sub(executableStartOffset, executableEndOffset)

	local archiveStartOffset = zipApp.signature.executableSize + 1
	local archiveEndOffset = archiveStartOffset + zipApp.signature.archiveSize - 1
	zipApp.archive = fileContents:sub(archiveStartOffset, archiveEndOffset)

	zipApp.reader = miniz.new_reader_memory(zipApp.archive)

	return zipApp
end

function vfs.dofile(zipApp, filePath)
	validation.validateTable(zipApp, "zipApp")
	validation.validateString(filePath, "filePath")

	local reader = zipApp.reader
	for index = 1, reader:get_num_files() do
		if reader:get_filename(index) == filePath then
			local fileContents = reader:extract(index)
			return loadstring(fileContents, "@" .. filePath)()
		end
	end

	return nil, "Failed to load file " .. filePath .. " (no such entry exists)"
end

function vfs.extract(zipApp, filePath)
	validation.validateTable(zipApp, "zipApp")
	validation.validateString(filePath, "filePath")

	local reader = zipApp.reader
	for index = 1, reader:get_num_files() do
		if reader:get_filename(index) == filePath then
			local fileContents = reader:extract(index)
			return fileContents
		end
	end

	return nil, "Failed to extract file " .. filePath .. " (no such entry exists)"
end

-- VFS searcher: Allow require to find files stored in the VFS of LUAZIP apps
-- See https://www.lua.org/manual/5.2/manual.html#pdf-package.searchers
function vfs.searcher(zipApp, moduleName)
	return function()
		local filePath = moduleName:gsub("%.", path.separator) .. ".lua"
		return vfs.dofile(zipApp, filePath)
	end
end

function vfs.dlopen(zipApp, libName)

	-- TODO support libhello.so, hello.dll, hello (FFI.load semantics)
	local uv = require("uv")
	local tempDirPath = uv.fs_mkdtemp(path.join(uv.cwd(), "LUAZIP-XXXXXX"))
	printf("Created temporary DLL/SO directory: %s", tempDirPath)
	local so = vfs.extract(zipApp, libName) -- TODO portability? see ffi load code, should be consistent - unit test!
	-- todo if not so then return nil, err -- allow chaining: vfs.dlopen or ffi.load = unit test!
	local tempLibPath = path.join(tempDirPath, libName)
	C_FileSystem.WriteFile(tempLibPath, so) -- TBD +x?
	dump(C_FileSystem.ReadDirectoryTree(tempDirPath)) -- TODO remove
	local vfsTestLib = ffi.load(tempLibPath)

	-- dump(vfsTestLib)
	-- local result = vfsTestLib.vfs_import_test(42)
	-- print(result)
	C_FileSystem.Delete(tempDirPath)

	return vfsTestLib
end

ffi.cdef(vfs.cdefs)

return vfs
