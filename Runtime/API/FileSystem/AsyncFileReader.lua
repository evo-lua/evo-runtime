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
		"FILE_CONTENTS_AVAILABLE",
		"FILE_DESCRIPTOR_CLOSED",
	},
	completedRequests = {},
	failedRequests = {},
	pendingRequests = {},
}

etrace.register(AsyncFileReader.events)

function AsyncFileReader:GatherFileContents(fileSystemPaths)
	-- TBD what if already gathering? add to gather, update max count
	EVENT("ASYNC_GATHER_STARTED", { fileSystemPaths = fileSystemPaths })

	for index, fileSystemPath in ipairs(fileSystemPaths) do
		-- TBD what if already loading this file? Then, discard or error?
		self:StartFileRequest(fileSystemPath)
	end
end

function AsyncFileReader:StartFileRequest(fileSystemPath)
	self.pendingRequests[fileSystemPath] = true
	-- TBD store uv requests also? or pass as payload
	uv.fs_open(fileSystemPath, "r", 438, function(err, fileDescriptor)
		-- handle err: if err then set failed, emit event, cancel request
		EVENT("FILE_DESCRIPTOR_OPENED", { fileSystemPath = fileSystemPath, fileDescriptor = fileDescriptor })
	end)

	EVENT("FILE_REQUEST_STARTED", { fileSystemPath = fileSystemPath })
end

function AsyncFileReader:LoadFileContents(fileSystemPath)
	EVENT("ASYNC_LOAD_STARTED", { fileSystemPath = fileSystemPath })
end

function AsyncFileReader:FILE_DESCRIPTOR_OPENED(event, payload)
	-- TBD simpler way, just fs_read directly?
	uv.fs_fstat(payload.fileDescriptor, function(err, stat)
		-- if err then return callback(err) end
		EVENT(
			"FILE_STATUS_AVAILABLE",
			{ fileSystemPath = payload.fileSystemPath, fileDescriptor = payload.fileDescriptor, stat = stat }
		)
	end)
end

function AsyncFileReader:FILE_STATUS_AVAILABLE(event, payload)
	-- TBD buffered reading, not all in one go
	uv.fs_read(payload.fileDescriptor, payload.stat.size, 0, function(err, data)
		EVENT(
			"FILE_CONTENTS_AVAILABLE",
			{ fileSystemPath = payload.fileSystemPath, data = data, fileDescriptor = payload.fileDescriptor }
		)
	end)
end

function AsyncFileReader:FILE_CONTENTS_AVAILABLE(event, payload)
	uv.fs_close(payload.fileDescriptor, function()
		EVENT("FILE_DESCRIPTOR_CLOSED", {
			fileSystemPath = payload.fileSystemPath,
			fileDescriptor = payload.fileDescriptor,
			fileContents = payload.data,
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
etrace.subscribe("FILE_STATUS_AVAILABLE", AsyncFileReader) -- FILE_STATUS_AVAILABLE?
etrace.subscribe("FILE_CONTENTS_AVAILABLE", AsyncFileReader)
etrace.subscribe("FILE_DESCRIPTOR_CLOSED", AsyncFileReader)

return AsyncFileReader
