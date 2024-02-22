local etrace = require("etrace")
local uv = require("uv")

local AsyncFileReader = {
	events = {
		"ASYNC_GATHER_STARTED",
		"ASYNC_GATHER_COMPLETED",
		"FILE_REQUEST_STARTED",
		"FILE_REQUEST_FAILED",
		"FILE_REQUEST_COMPLETED",
		"FILE_DESCRIPTOR_OPENED",
		"FILE_STATUS_AVAILABLE",
		"FILE_CHUNK_AVAILABLE",
		"FILE_CONTENTS_AVAILABLE",
		"FILE_DESCRIPTOR_CLOSED",
	},
	completedRequests = {},
	failedRequests = {},
	pendingRequests = {},
	FILE_MODE_READONLY = 292, -- Octal: 444
	CHUNK_SIZE_IN_BYTES = 1024 * 256,
}

etrace.register(AsyncFileReader.events)

function AsyncFileReader:GatherFileContents(fileSystemPaths)
	-- TBD what if already gathering? add to gather, update max count
	EVENT("ASYNC_GATHER_STARTED", { fileSystemPaths = fileSystemPaths })

	for index, fileSystemPath in ipairs(fileSystemPaths) do
		-- TBD what if already loading this file? Then, discard or error?
		self:LoadFileContents(fileSystemPath)
	end
end

function AsyncFileReader:LoadFileContents(fileSystemPath)
	self.pendingRequests[fileSystemPath] = true
	uv.fs_open(fileSystemPath, "r", AsyncFileReader.FILE_MODE_READONLY, function(errorMessage, fileDescriptor)
		if errorMessage then
			EVENT("FILE_REQUEST_FAILED", { fileSystemPath = fileSystemPath, message = errorMessage })
			return
		end

		EVENT("FILE_DESCRIPTOR_OPENED", { fileSystemPath = fileSystemPath, fileDescriptor = fileDescriptor })
	end)

	EVENT("FILE_REQUEST_STARTED", { fileSystemPath = fileSystemPath })
end

function AsyncFileReader:FILE_DESCRIPTOR_OPENED(event, payload)
	uv.fs_fstat(payload.fileDescriptor, function(errorMessage, stat)
		if errorMessage then
			EVENT("FILE_REQUEST_FAILED", { fileSystemPath = payload.fileSystemPath, message = errorMessage })
			return
		end

		EVENT(
			"FILE_STATUS_AVAILABLE",
			{ fileSystemPath = payload.fileSystemPath, fileDescriptor = payload.fileDescriptor, stat = stat }
		)
	end)
end

function AsyncFileReader:FILE_STATUS_AVAILABLE(event, payload)
	local currentChunkIndex = math.ceil(payload.stat.size / AsyncFileReader.CHUNK_SIZE_IN_BYTES)
	payload.currentChunkIndex = currentChunkIndex
	if currentChunkIndex == 1 then
		uv.fs_read(payload.fileDescriptor, payload.stat.size, 0, function(errorMessage, chunkBytes)
			if errorMessage then
				EVENT("FILE_REQUEST_FAILED", { fileSystemPath = payload.fileSystemPath, message = errorMessage })
				return
			end

			EVENT("FILE_CHUNK_AVAILABLE", {
				fileSystemPath = payload.fileSystemPath,
				chunkBytes = chunkBytes,
				maxChunkIndex = 1,
				currentChunkIndex = 1,
				fileDescriptor = payload.fileDescriptor,
			})
			EVENT("FILE_CONTENTS_AVAILABLE", {
				fileSystemPath = payload.fileSystemPath,
				maxChunkIndex = payload.maxChunkIndex,
				currentChunkIndex = payload.currentChunkIndex,
				fileDescriptor = payload.fileDescriptor,
			})
		end)
	else
		payload.maxChunkIndex = 0 -- TBD initialize and reuse payload table, only update as needed
		self:ReadFileInChunks(payload.fileDescriptor, payload.fileSystemPath, payload.stat.size, 0, payload)
	end
end

function AsyncFileReader:ReadFileInChunks(fileDescriptor, fileSystemPath, fileSize, offset, payload)
	-- accumulatedData = accumulatedData or ""
	payload.maxChunkIndex = payload.maxChunkIndex + 1
	local toRead = math.min(AsyncFileReader.CHUNK_SIZE_IN_BYTES, fileSize - offset)
	if toRead <= 0 then
		EVENT(
			"FILE_CONTENTS_AVAILABLE",
			{ fileSystemPath = fileSystemPath, maxChunkIndex = payload.maxChunkIndex, fileDescriptor = fileDescriptor }
		)
	else
		uv.fs_read(fileDescriptor, toRead, offset, function(errorMessage, chunkBytes)
			if errorMessage then
				EVENT("FILE_REQUEST_FAILED", { fileSystemPath = fileSystemPath, message = errorMessage })
				return
			end

			EVENT(
				"FILE_CHUNK_AVAILABLE",
				{
					fileSystemPath = fileSystemPath,
					chunkBytes = chunkBytes,
					maxChunkIndex = payload.maxChunkIndex,
					currentChunkIndex = payload.currentChunkIndex,
					fileDescriptor = fileDescriptor,
				} -- TODO chunkBytes -> lastChunk
			)

			-- local newAccumulatedData = accumulatedData .. chunk
			local newOffset = offset + toRead
			if newOffset < fileSize then
				self:ReadFileInChunks(fileDescriptor, fileSystemPath, fileSize, newOffset, payload)
			else
				EVENT("FILE_CONTENTS_AVAILABLE", { fileSystemPath = fileSystemPath, fileDescriptor = fileDescriptor })
			end
		end)
	end
end

function AsyncFileReader:FILE_CONTENTS_AVAILABLE(event, payload)
	uv.fs_close(payload.fileDescriptor, function()
		EVENT("FILE_DESCRIPTOR_CLOSED", {
			fileSystemPath = payload.fileSystemPath,
			fileDescriptor = payload.fileDescriptor,
			-- fileContents = payload.chunk,
			-- maxChunkIndex = payload.maxChunkIndex,
		})
	end)
end

function AsyncFileReader:FILE_DESCRIPTOR_CLOSED(event, payload)
	self.pendingRequests[payload.fileSystemPath] = nil
	self.completedRequests[payload.fileSystemPath] = payload.fileContents
	EVENT("FILE_REQUEST_COMPLETED", { fileSystemPath = payload.fileSystemPath })

	if table.count(self.pendingRequests) == 0 and table.count(self.failedRequests) == 0 then
		EVENT("ASYNC_GATHER_COMPLETED", { completedRequests = self.completedRequests })
	end
end

etrace.subscribe("FILE_DESCRIPTOR_OPENED", AsyncFileReader)
etrace.subscribe("FILE_STATUS_AVAILABLE", AsyncFileReader)
-- etrace.subscribe("FILE_CHUNK_AVAILABLE", AsyncFileReader)
etrace.subscribe("FILE_CONTENTS_AVAILABLE", AsyncFileReader)
etrace.subscribe("FILE_DESCRIPTOR_CLOSED", AsyncFileReader)

return AsyncFileReader
