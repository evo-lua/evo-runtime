local etrace = require("etrace")
local uv = require("uv")

local math_ceil = math.ceil

local AsyncFileReader = {
	events = {
		"FILE_REQUEST_STARTED",
		"FILE_REQUEST_FAILED",
		"FILE_REQUEST_COMPLETED",
		"FILE_DESCRIPTOR_OPENED",
		"FILE_STATUS_AVAILABLE",
		"FILE_CHUNK_AVAILABLE",
		"FILE_CONTENTS_AVAILABLE",
		"FILE_DESCRIPTOR_CLOSED",
	},
	FILE_MODE_READONLY = 292, -- Octal: 444
	CHUNK_SIZE_IN_BYTES = 1024 * 256,
}

etrace.register(AsyncFileReader.events)

function AsyncFileReader:LoadFileContents(fileSystemPath)
	local payload = {
		fileSystemPath = fileSystemPath,
	}

	uv.fs_open(fileSystemPath, "r", AsyncFileReader.FILE_MODE_READONLY, function(errorMessage, fileDescriptor)
		payload.errorMessage = errorMessage
		payload.fileDescriptor = fileDescriptor

		if errorMessage then
			EVENT("FILE_REQUEST_FAILED", payload)
			return
		end

		EVENT("FILE_DESCRIPTOR_OPENED", payload)
	end)

	EVENT("FILE_REQUEST_STARTED", payload)
end

function AsyncFileReader:FILE_DESCRIPTOR_OPENED(event, payload)
	uv.fs_fstat(payload.fileDescriptor, function(errorMessage, stat)
		payload.errorMessage = errorMessage
		payload.stat = stat

		if errorMessage then
			EVENT("FILE_REQUEST_FAILED", payload)
			return
		end

		EVENT("FILE_STATUS_AVAILABLE", payload)
	end)
end

function AsyncFileReader:FILE_STATUS_AVAILABLE(event, payload)
	payload.lastChunkIndex = math_ceil(payload.stat.size / AsyncFileReader.CHUNK_SIZE_IN_BYTES)
	payload.chunkIndex = 0
	payload.cursorPosition = 0

	if payload.stat.type == "directory" then
		-- On Windows, read requests on directories succeed without returning any data
		-- Simulating the error returned on other platforms here allows providing a consistent interface
		payload.errorMessage = "EISDIR: illegal operation on a directory" -- Should use uv_strerror but it isn't currently bound
		EVENT("FILE_REQUEST_FAILED", payload)
		return
	end

	self:ReadNextFileChunk(payload)
end

function AsyncFileReader:ReadNextFileChunk(payload)
	-- Consecutive chunked reads may overwrite the payload unless copied
	payload = table.scopy(payload)

	local totalFileSizeInBytes = payload.stat.size
	local startOffset = payload.cursorPosition

	local numLeftoverBytes = math.min(AsyncFileReader.CHUNK_SIZE_IN_BYTES, totalFileSizeInBytes - startOffset)
	if numLeftoverBytes <= 0 then
		EVENT("FILE_CONTENTS_AVAILABLE", payload)
		return
	end

	uv.fs_read(payload.fileDescriptor, numLeftoverBytes, startOffset, function(errorMessage, chunk)
		payload.errorMessage = errorMessage
		payload.chunk = chunk

		if errorMessage then
			EVENT("FILE_REQUEST_FAILED", payload)
			return
		end

		EVENT("FILE_CHUNK_AVAILABLE", payload)

		local newOffset = startOffset + numLeftoverBytes
		payload.cursorPosition = newOffset
		if newOffset < totalFileSizeInBytes then
			return self:ReadNextFileChunk(payload)
		end

		EVENT("FILE_CONTENTS_AVAILABLE", payload)
	end)

	payload.chunkIndex = payload.chunkIndex + 1
end

function AsyncFileReader:FILE_CONTENTS_AVAILABLE(event, payload)
	uv.fs_close(payload.fileDescriptor, function()
		EVENT("FILE_DESCRIPTOR_CLOSED", payload)
	end)

	EVENT("FILE_REQUEST_COMPLETED", payload)
end

function AsyncFileReader:FILE_REQUEST_FAILED(event, payload)
	if not payload.fileDescriptor then
		return
	end

	uv.fs_close(payload.fileDescriptor, function()
		EVENT("FILE_DESCRIPTOR_CLOSED", payload)
	end)
end

etrace.subscribe("FILE_DESCRIPTOR_OPENED", AsyncFileReader)
etrace.subscribe("FILE_STATUS_AVAILABLE", AsyncFileReader)
etrace.subscribe("FILE_CONTENTS_AVAILABLE", AsyncFileReader)
etrace.subscribe("FILE_REQUEST_FAILED", AsyncFileReader)

return AsyncFileReader
