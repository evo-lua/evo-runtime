local uv = require("uv")

local path_join = path.join

local C_FileSystem = {}

function C_FileSystem.Exists(path)
	return uv.fs_access(path, "R")
end

function C_FileSystem.IsFile(path)
	local fileAttributes = uv.fs_stat(path)
	if not fileAttributes then
		return false
	end

	return fileAttributes.type == "file"
end

function C_FileSystem.IsDirectory(path)
	local fileAttributes = uv.fs_stat(path)
	if not fileAttributes then
		return false
	end

	return fileAttributes.type == "directory"
end

function C_FileSystem.Delete(path)
	if not C_FileSystem.Exists(path) then
		return true
	end

	if C_FileSystem.IsDirectory(path) then
		return uv.fs_rmdir(path)
	end

	return uv.fs_unlink(path)
end

function C_FileSystem.MakeDirectory(path)
	if C_FileSystem.Exists(path) then
		return false
	end

	return uv.fs_mkdir(path, 511)
end

function C_FileSystem.MakeDirectoryTree(path)
	local parent = path_join(path, "..")
	if not C_FileSystem.Exists(parent) then
		local status, error = C_FileSystem.MakeDirectoryTree(parent)
		if not status then
			return false, error
		end
	end

	if C_FileSystem.Exists(path) then
		if C_FileSystem.IsDirectory(path) then
			return true
		else
			return false, "Path exists but is not a directory"
		end
	end

	local status, error = uv.fs_mkdir(path, 511)
	if not status then
		return false, error
	end

	return true
end

function C_FileSystem.ReadFile(path)
	local fileDescriptor, fileAttributes, fileContents, errorMessage
	fileDescriptor, errorMessage = uv.fs_open(path, "r", 438)

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

function C_FileSystem.ReadDirectory(path, isRecursiveMode)
	local libuvFileSystemRequest, errorMessage = uv.fs_scandir(path)

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
		local absolutePath = path_join(path, name)
		if canWalkRecursively and isRecursiveMode then
			local files = C_FileSystem.ReadDirectory(absolutePath, isRecursiveMode)
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

function C_FileSystem.WriteFile(path, contents)
	local fileDescriptor, errorMessage = uv.fs_open(path, "w", 438)
	if not fileDescriptor then
		error(errorMessage, 0)
	end

	uv.fs_write(fileDescriptor, contents)
	uv.fs_close(fileDescriptor)

	return true
end

function C_FileSystem.AppendFile(path, contents)
	local fileDescriptor, errorMessage = uv.fs_open(path, "a", 438)
	if not fileDescriptor then
		error(errorMessage, 0)
	end

	uv.fs_write(fileDescriptor, contents)
	uv.fs_close(fileDescriptor)

	return true
end

return C_FileSystem
