local uv = require("uv")

local path_join = path.join

local C_FileSystem = {}

function C_FileSystem.Exists(fileSystemPath)
	return uv.fs_access(fileSystemPath, "R")
end

function C_FileSystem.IsFile(fileSystemPath)
	local fileAttributes = uv.fs_stat(fileSystemPath)
	if not fileAttributes then
		return false
	end

	return fileAttributes.type == "file"
end

function C_FileSystem.IsDirectory(fileSystemPath)
	local fileAttributes = uv.fs_stat(fileSystemPath)
	if not fileAttributes then
		return false
	end

	return fileAttributes.type == "directory"
end

function C_FileSystem.Delete(fileSystemPath)
	if not C_FileSystem.Exists(fileSystemPath) then
		return true
	end

	if C_FileSystem.IsDirectory(fileSystemPath) then
		return uv.fs_rmdir(fileSystemPath)
	end

	return uv.fs_unlink(fileSystemPath)
end

function C_FileSystem.MakeDirectory(directoryPath)
	if C_FileSystem.Exists(directoryPath) then
		return false
	end

	return uv.fs_mkdir(directoryPath, 511)
end

function C_FileSystem.MakeDirectoryTree(directoryPath)
	local parent = path_join(directoryPath, "..")
	if not C_FileSystem.Exists(parent) then
		local status, error = C_FileSystem.MakeDirectoryTree(parent)
		if not status then
			return false, error
		end
	end

	if C_FileSystem.Exists(directoryPath) then
		if C_FileSystem.IsDirectory(directoryPath) then
			return true
		else
			return false, "Path exists but is not a directory"
		end
	end

	local status, error = uv.fs_mkdir(directoryPath, 511)
	if not status then
		return false, error
	end

	return true
end

function C_FileSystem.ReadFile(filePath)
	local fileDescriptor, fileAttributes, fileContents, errorMessage
	fileDescriptor, errorMessage = uv.fs_open(filePath, "r", 438)

	if not fileDescriptor then -- Nothing to close
		error(errorMessage, 0)
	end

	fileAttributes, errorMessage = uv.fs_fstat(fileDescriptor)
	if not fileAttributes then
		uv.fs_close(fileDescriptor)
		error(errorMessage, 0)
	end

	fileContents, errorMessage = uv.fs_read(fileDescriptor, fileAttributes.size)
	if not fileContents then
		uv.fs_close(fileDescriptor)
		error(errorMessage, 0)
	end

	uv.fs_close(fileDescriptor)

	return fileContents
end

local function readDirectory(filePath, isRecursiveMode)
	local libuvFileSystemRequest, errorMessage = uv.fs_scandir(filePath)

	if not libuvFileSystemRequest then
		error(errorMessage, 0)
	end

	local directoryContents = {}

	while true do
		local name, type = uv.fs_scandir_next(libuvFileSystemRequest)
		if not name then
			break
		end

		local canWalkRecursively = (type == "directory")
		local absolutePath = path_join(filePath, name)
		if canWalkRecursively and isRecursiveMode then
			local files = isRecursiveMode and C_FileSystem.ReadDirectoryTree(absolutePath)
				or C_FileSystem.ReadDirectory(absolutePath)
			for key, value in pairs(files) do
				directoryContents[key] = value
			end
		elseif isRecursiveMode then
			directoryContents[absolutePath] = true
		else
			directoryContents[name] = true
		end
	end

	return directoryContents
end

function C_FileSystem.ReadDirectory(filePath)
	return readDirectory(filePath, false)
end

function C_FileSystem.ReadDirectoryTree(filePath)
	return readDirectory(filePath, true)
end

function C_FileSystem.WriteFile(filePath, contents)
	local fileDescriptor, errorMessage = uv.fs_open(filePath, "w", 438)
	if not fileDescriptor then
		error(errorMessage, 0)
	end

	uv.fs_write(fileDescriptor, contents)
	uv.fs_close(fileDescriptor)

	return true
end

function C_FileSystem.AppendFile(filePath, contents)
	local fileDescriptor, errorMessage = uv.fs_open(filePath, "a", 438)
	if not fileDescriptor then
		error(errorMessage, 0)
	end

	uv.fs_write(fileDescriptor, contents)
	uv.fs_close(fileDescriptor)

	return true
end

return C_FileSystem
