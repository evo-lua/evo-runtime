-- Originally ported from the NodeJS source code @ 0d2b6aca60 (latest HEAD on 2021/10/05)

-- Copyright Joyent, Inc. and other Node contributors.
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to permit
-- persons to whom the Software is furnished to do so, subject to the
-- following conditions:
--
-- The above copyright notice and this permission notice shall be included
-- in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
-- OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
-- NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
-- DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
-- USE OR OTHER DEALINGS IN THE SOFTWARE.

local ffi = require("ffi")
local uv = require("uv")
local v8 = require("v8")

-- Upvalues
local stringPrototypeLastIndexOf = v8.stringPrototypeLastIndexOf
local string_find = string.find
local string_gsub = string.gsub
local string_lower = string.lower
local string_sub = string.sub
local format = string.format
local type = type

-- Character codes
local CHAR_UPPERCASE_A = 65
local CHAR_LOWERCASE_A = 97
local CHAR_UPPERCASE_Z = 90
local CHAR_LOWERCASE_Z = 122
local CHAR_DOT = 46
local CHAR_FORWARD_SLASH = 47
local CHAR_BACKWARD_SLASH = 92
local CHAR_COLON = 58

local win32 = {
	separator = "\\",
	delimiter = ";",
	convention = "Windows",
}

local posix = {
	separator = "/",
	delimiter = ":",
	convention = "POSIX",
}

local function stringCharAt(str, index)
	return str:sub(index, index + 1)
end

local function stringCharCodeAt(str, index)
	return stringCharAt(str, index):byte()
end

local function stringPrototypeCharCodeAt(str, index)
	-- To offset for Lua indices starting at 1
	index = index + 1
	return stringCharCodeAt(str, index)
end

local function stringPrototypeSlice(str, i, j)
	-- To offset for Lua indices starting at 1
	if i ~= nil then
		i = i + 1
	end

	return string_sub(str, i, j)
end

local function stringPrototypeToLowerCase(str)
	return string_lower(str)
end

local function isPathSeparator(code)
	return code == CHAR_FORWARD_SLASH or code == CHAR_BACKWARD_SLASH
end

local function isPosixPathSeparator(code)
	return code == CHAR_FORWARD_SLASH
end

local function isWindowsDeviceRoot(code)
	return (code >= CHAR_UPPERCASE_A and code <= CHAR_UPPERCASE_Z)
		or (code >= CHAR_LOWERCASE_A and code <= CHAR_LOWERCASE_Z)
end

-- Resolves . and .. elements in a path with directory names
local function normalizeString(path, allowAboveRoot, separator, isPathSeparatorCharacter)
	local res = ""
	local lastSegmentLength = 0
	local lastSlash = -1
	local dots = 0
	local code = 0

	for i = 0, #path, 1 do
		local continue = false
		if i < #path then
			code = stringPrototypeCharCodeAt(path, i)
		elseif isPathSeparatorCharacter(code) then
			break
		else
			code = CHAR_FORWARD_SLASH
		end

		if isPathSeparatorCharacter(code) then
			if lastSlash == i - 1 or dots == 1 then
				-- NOOP
				dots = dots -- Remove this when (if) this mess is ever refactored
			elseif dots == 2 then
				if
					#res < 2
					or lastSegmentLength ~= 2
					or stringPrototypeCharCodeAt(res, #res - 1) ~= CHAR_DOT
					or stringPrototypeCharCodeAt(res, #res - 2) ~= CHAR_DOT
				then
					if #res > 2 then
						local lastSlashIndex = stringPrototypeLastIndexOf(res, separator)
						if lastSlashIndex == -1 then
							res = ""
							lastSegmentLength = 0
						else
							res = stringPrototypeSlice(res, 0, lastSlashIndex)
							lastSegmentLength = #res - 1 - stringPrototypeLastIndexOf(res, separator)
						end
						lastSlash = i
						dots = 0
						continue = true
					elseif #res ~= 0 then
						res = ""
						lastSegmentLength = 0
						lastSlash = i
						dots = 0
						continue = true
					end
				end

				if not continue then
					if allowAboveRoot then
						res = res .. (#res > 0 and (separator .. "..") or "..")
						lastSegmentLength = 2
					end
				end
			else
				if #res > 0 then
					res = res .. separator .. stringPrototypeSlice(path, lastSlash + 1, i)
				else
					res = stringPrototypeSlice(path, lastSlash + 1, i)
				end
				lastSegmentLength = i - lastSlash - 1
			end

			if not continue then
				lastSlash = i
				dots = 0
			end
		elseif code == CHAR_DOT and dots ~= -1 then
			dots = dots + 1
		else
			dots = -1
		end
	end

	return res
end

function win32.resolve(...)
	local args = { ... }

	local resolvedDevice = ""
	local resolvedTail = ""
	local resolvedAbsolute = false

	if #args == 0 then
		return nil, "Usage: resolve(path1[, path2, path3, ..., pathN])"
	end

	-- Special case: one argument (not checked below, for some reason?)
	if type(args[1]) ~= "string" then
		return nil, "Usage: resolve(path1[, path2, path3, ..., pathN])"
	end

	for i = #args, 0, -1 do -- Offset by 1 in Lua
		local continue = false -- skip to next iteration if true

		local path
		if i >= 1 then -- Resolve root separately to deal with UNC issues
			path = args[i]

			if type(path) ~= "string" then
				return nil, "Usage: resolve(path1[, path2, path3, ..., pathN])"
			end

			-- Skip empty entries
			if #path == 0 then
				continue = true
			end
		elseif #resolvedDevice == 0 then
			path = uv.cwd()
		else
			-- Windows has the concept of drive-specific current working
			-- directories. If we've resolved a drive letter but not yet an
			-- absolute path, get cwd for that drive, or the process cwd if
			-- the drive cwd is not available. We're sure the device is not
			-- a UNC path at this points, because UNC paths are always absolute.

			-- The current directory state written by the SetCurrentDirectory function is stored as a global variable in each process
			-- See https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getcurrentdirectory
			-- This is a virtual environment variable stored by the DOS command processor and it doesn't actually exist...
			path = uv.os_getenv("=" .. resolvedDevice) or uv.cwd()

			-- Verify that a cwd was found and that it actually points
			-- to our drive. If not, default to the drive's root.
			if
				path == nil
				or (
					stringPrototypeToLowerCase(stringPrototypeSlice(path, 0, 2))
						~= stringPrototypeToLowerCase(resolvedDevice)
					and stringPrototypeCharCodeAt(path, 2) == CHAR_BACKWARD_SLASH
				)
			then
				path = resolvedDevice .. "\\"
			end
		end

		if not continue then -- continue 1
			local len = #path
			local rootEnd = 0
			local device = ""
			local isAbsolute = false
			local code = stringPrototypeCharCodeAt(path, 0)

			-- Try to match a root
			if len == 1 then
				if isPathSeparator(code) then
					-- `path` contains just a path separator
					rootEnd = 1
					isAbsolute = true
				end
			elseif isPathSeparator(code) then
				-- Possible UNC root
				-- If we started with a separator, we know we at least have an
				-- absolute path of some kind (UNC or otherwise)
				isAbsolute = true

				if isPathSeparator(stringPrototypeCharCodeAt(path, 1)) then
					-- Matched double path separator at beginning
					local j = 2
					local last = j
					-- Match 1 or more non-path separators
					while j < len and not isPathSeparator(stringPrototypeCharCodeAt(path, j)) do
						j = j + 1
					end
					if j < len and j ~= last then
						local firstPart = stringPrototypeSlice(path, last, j)
						-- Matched!
						last = j
						-- Match 1 or more path separators
						while j < len and isPathSeparator(stringPrototypeCharCodeAt(path, j)) do
							j = j + 1
						end
						if j < len and j ~= last then
							-- Matched!
							last = j
							-- Match 1 or more non-path separators
							while j < len and not isPathSeparator(stringPrototypeCharCodeAt(path, j)) do
								j = j + 1
							end
							if j == len or j ~= last then
								-- We matched a UNC root
								device = "\\\\" .. firstPart .. "\\" .. stringPrototypeSlice(path, last, j)
								rootEnd = j
							end
						end
					end
				else
					rootEnd = 1
				end
			elseif isWindowsDeviceRoot(code) and stringPrototypeCharCodeAt(path, 1) == CHAR_COLON then
				-- Possible device root
				device = stringPrototypeSlice(path, 0, 2)
				rootEnd = 2
				if len > 2 and isPathSeparator(stringPrototypeCharCodeAt(path, 2)) then
					-- Treat separator following drive name as an absolute path
					-- indicator
					isAbsolute = true
					rootEnd = 3
				end
			end

			if #device > 0 then
				if #resolvedDevice > 0 then
					if stringPrototypeToLowerCase(device) ~= stringPrototypeToLowerCase(resolvedDevice) then
						-- This path points to another device so it is not applicable
						continue = true
					end
				else
					resolvedDevice = device
				end
			end

			if not continue then
				if resolvedAbsolute then
					if #resolvedDevice > 0 then
						break
					end
				else
					resolvedTail = stringPrototypeSlice(path, rootEnd) .. "\\" .. resolvedTail
					resolvedAbsolute = isAbsolute
					if isAbsolute and #resolvedDevice > 0 then
						break
					end
				end
			end
		end
	end

	-- At this point the path should be resolved to a full absolute path,
	-- but handle relative paths to be safe (might happen when process.cwd()
	-- fails)

	-- Normalize the tail path
	resolvedTail = normalizeString(resolvedTail, not resolvedAbsolute, "\\", isPathSeparator)

	return ((resolvedAbsolute and (resolvedDevice .. "\\" .. resolvedTail)) or resolvedDevice .. resolvedTail) or "."
end

function win32.normalize(path)
	if type(path) ~= "string" then
		return nil, "Usage: normalize(path)"
	end

	local len = #path
	if len == 0 then
		return "."
	end
	local rootEnd = 0
	local device
	local isAbsolute = false
	local code = stringPrototypeCharCodeAt(path, 0)

	-- Try to match a root
	if len == 1 then
		-- `path` contains just a single char, exit early to avoid
		-- unnecessary work
		return isPosixPathSeparator(code) and "\\" or path
	end
	if isPathSeparator(code) then
		-- Possible UNC root

		-- If we started with a separator, we know we at least have an absolute
		-- path of some kind (UNC or otherwise)
		isAbsolute = true

		if isPathSeparator(stringPrototypeCharCodeAt(path, 1)) then
			-- Matched double path separator at beginning
			local j = 2
			local last = j
			-- Match 1 or more non-path separators
			while j < len and not isPathSeparator(stringPrototypeCharCodeAt(path, j)) do
				j = j + 1
			end
			if j < len and j ~= last then
				local firstPart = stringPrototypeSlice(path, last, j)
				-- Matchednot
				last = j
				-- Match 1 or more path separators
				while j < len and isPathSeparator(stringPrototypeCharCodeAt(path, j)) do
					j = j + 1
				end
				if j < len and j ~= last then
					-- Matchednot
					last = j
					-- Match 1 or more non-path separators
					while j < len and not isPathSeparator(stringPrototypeCharCodeAt(path, j)) do
						j = j + 1
					end
					if j == len then
						-- We matched a UNC root only
						-- Return the normalized version of the UNC root since there
						-- is nothing left to process
						return format("\\\\%s\\%s\\", firstPart, stringPrototypeSlice(path, last))
					end
					if j ~= last then
						-- We matched a UNC root with leftovers
						device = format("\\\\%s\\%s", firstPart, stringPrototypeSlice(path, last, j))
						rootEnd = j
					end
				end
			end
		else
			rootEnd = 1
		end
	elseif isWindowsDeviceRoot(code) and stringPrototypeCharCodeAt(path, 1) == CHAR_COLON then
		-- Possible device root
		device = stringPrototypeSlice(path, 0, 2)
		rootEnd = 2
		if len > 2 and isPathSeparator(stringPrototypeCharCodeAt(path, 2)) then
			-- Treat separator following drive name as an absolute path
			-- indicator
			isAbsolute = true
			rootEnd = 3
		end
	end

	local tail = (rootEnd < len)
			and normalizeString(stringPrototypeSlice(path, rootEnd), not isAbsolute, "\\", isPathSeparator)
		or ""
	if #tail == 0 and not isAbsolute then
		tail = "."
	end
	if #tail > 0 and isPathSeparator(stringPrototypeCharCodeAt(path, len - 1)) then
		tail = tail .. "\\"
	end
	if device == nil then
		return isAbsolute and format("\\%s", tail) or tail
	end
	return isAbsolute and format("%s\\%s", device, tail) or format("%s%s", device, tail)
end

function win32.isAbsolute(path)
	if type(path) ~= "string" then
		return nil, "Usage: isAbsolute(path)"
	end

	local len = #path
	if len == 0 then
		return false
	end
	local code = stringPrototypeCharCodeAt(path, 0)
	return isPathSeparator(code)
		-- Possible device root
		or (
			len > 2
			and isWindowsDeviceRoot(code)
			and stringPrototypeCharCodeAt(path, 1) == CHAR_COLON
			and isPathSeparator(stringPrototypeCharCodeAt(path, 2))
		)
end

function win32.join(...)
	local args = { ... }

	if #args == 0 then
		return "."
	end

	local joined
	local firstPart

	for i = 1, #args, 1 do
		local arg = args[i]

		if type(arg) ~= "string" then
			return nil, "Usage: path.join(path)"
		end

		if #arg > 0 then
			if joined == nil then
				joined = arg
				firstPart = arg
			else
				joined = joined .. "\\" .. arg
			end
		end
	end

	if joined == nil then
		return "."
	end
	-- Make sure that the joined path doesn't start with two slashes, because
	-- normalize() will mistake it for a UNC path then.
	--
	-- This step is skipped when it is very clear that the user actually
	-- intended to point at a UNC path. This is assumed when the first
	-- non-empty string arguments starts with exactly two slashes followed by
	-- at least one more non-slash character.
	--
	-- Note that for normalize() to treat a path as a UNC path it needs to
	-- have at least 2 components, so we don't filter for that here.
	-- This means that the user can use join to construct UNC paths from
	-- a server name and a share name for example:
	--   path.join('//server', 'share') -> '\\\\server\\share\\')
	local needsReplace = true
	local slashCount = 0
	if isPathSeparator(stringPrototypeCharCodeAt(firstPart, 0)) then
		slashCount = slashCount + 1
		local firstLen = #firstPart
		if firstLen > 1 and isPathSeparator(stringPrototypeCharCodeAt(firstPart, 1)) then
			slashCount = slashCount + 1
			if firstLen > 2 then
				if isPathSeparator(stringPrototypeCharCodeAt(firstPart, 2)) then
					slashCount = slashCount + 1
				else
					-- We matched a UNC path in the first part
					needsReplace = false
				end
			end
		end
	end

	if needsReplace then
		-- Find any more consecutive slashes we need to replace
		while slashCount < #joined and isPathSeparator(stringPrototypeCharCodeAt(joined, slashCount)) do
			slashCount = slashCount + 1
		end

		-- Replace the slashes if needed
		if slashCount >= 2 then
			joined = "\\" .. stringPrototypeSlice(joined, slashCount)
		end
	end

	return win32.normalize(joined)
end

function win32.relative(from, to)
	if type(from) ~= "string" then
		return nil, "Usage: convert(from, to)"
	end
	if type(to) ~= "string" then
		return nil, "Usage: convert(from, to)"
	end

	if from == to then
		return ""
	end

	local fromOrig = win32.resolve(from)
	local toOrig = win32.resolve(to)

	if fromOrig == toOrig then
		return ""
	end

	from = stringPrototypeToLowerCase(fromOrig)
	to = stringPrototypeToLowerCase(toOrig)

	if from == to then
		return ""
	end

	-- Trim any leading backslashes
	local fromStart = 0
	while fromStart < #from and stringPrototypeCharCodeAt(from, fromStart) == CHAR_BACKWARD_SLASH do
		fromStart = fromStart + 1
	end
	-- Trim trailing backslashes (applicable to UNC paths only)
	local fromEnd = #from
	while fromEnd - 1 > fromStart and stringPrototypeCharCodeAt(from, fromEnd - 1) == CHAR_BACKWARD_SLASH do
		fromEnd = fromEnd - 1
	end
	local fromLen = fromEnd - fromStart

	-- Trim any leading backslashes
	local toStart = 0
	while toStart < #to and stringPrototypeCharCodeAt(to, toStart) == CHAR_BACKWARD_SLASH do
		toStart = toStart + 1
	end
	-- Trim trailing backslashes (applicable to UNC paths only)
	local toEnd = #to
	while toEnd - 1 > toStart and stringPrototypeCharCodeAt(to, toEnd - 1) == CHAR_BACKWARD_SLASH do
		toEnd = toEnd - 1
	end
	local toLen = toEnd - toStart

	-- Compare paths to find the longest common path from root
	local length
	if fromLen < toLen then
		length = fromLen
	else
		length = toLen
	end

	local lastCommonSep = -1
	local i = 0
	for l = 0, length, 1 do
		i = l
		local fromCode = stringPrototypeCharCodeAt(from, fromStart + l)
		if fromCode ~= stringPrototypeCharCodeAt(to, toStart + l) then
			break
		elseif fromCode == CHAR_BACKWARD_SLASH then
			lastCommonSep = l
		end
	end

	-- We found a mismatch before the first common path separator was seen, so
	-- return the original `to`.
	if i ~= length then
		if lastCommonSep == -1 then
			return toOrig
		end
	else
		if toLen > length then
			if stringPrototypeCharCodeAt(to, toStart + i) == CHAR_BACKWARD_SLASH then
				-- We get here if `from` is the exact base path for `to`.
				-- For example: from='C:\\foo\\bar' to='C:\\foo\\bar\\baz'
				return stringPrototypeSlice(toOrig, toStart + i + 1)
			end
			if i == 2 then
				-- We get here if `from` is the device root.
				-- For example: from='C:\\' to='C:\\foo'
				return stringPrototypeSlice(toOrig, toStart + i)
			end
		end
		if fromLen > length then
			if stringPrototypeCharCodeAt(from, fromStart + i) == CHAR_BACKWARD_SLASH then
				-- We get here if `to` is the exact base path for `from`.
				-- For example: from='C:\\foo\\bar' to='C:\\foo'
				lastCommonSep = i
			elseif i == 2 then
				-- We get here if `to` is the device root.
				-- For example: from='C:\\foo\\bar' to='C:\\'
				lastCommonSep = 3
			end
		end
		if lastCommonSep == -1 then
			lastCommonSep = 0
		end
	end

	local out = ""
	-- Generate the relative path based on the path difference between `to` and
	-- `from`
	-- lastCommonSep should be 7, but is 2...?
	for j = fromStart + lastCommonSep + 1, fromEnd, 1 do
		if j == fromEnd or stringPrototypeCharCodeAt(from, j) == CHAR_BACKWARD_SLASH then
			out = out .. ((#out == 0) and ".." or "\\..")
		end
	end

	toStart = toStart + lastCommonSep

	-- Lastly, append the rest of the destination (`to`) path that comes after
	-- the common path parts
	if #out > 0 then
		return out .. stringPrototypeSlice(toOrig, toStart, toEnd)
	end

	if stringPrototypeCharCodeAt(toOrig, toStart) == CHAR_BACKWARD_SLASH then
		toStart = toStart + 1
	end
	return stringPrototypeSlice(toOrig, toStart, toEnd)
end

function win32.dirname(path)
	if type(path) ~= "string" then
		return nil, "Usage: dirname(path)"
	end
	local len = #path
	if len == 0 then
		return "."
	end

	local rootEnd = -1
	local offset = 0
	local code = stringPrototypeCharCodeAt(path, 0)

	if len == 1 then
		-- `path` contains just a path separator, exit early to avoid
		-- unnecessary work or a dot.
		return isPathSeparator(code) and path or "."
	end

	-- Try to match a root
	if isPathSeparator(code) then
		-- Possible device root
		-- Possible UNC root

		rootEnd = 1
		offset = 1

		if isPathSeparator(stringPrototypeCharCodeAt(path, 1)) then
			-- Matched double path separator at beginning
			local j = 2
			local last = j
			-- Match 1 or more non-path separators
			while j < len and not isPathSeparator(stringPrototypeCharCodeAt(path, j)) do
				j = j + 1
			end
			if j < len and j ~= last then
				-- Matchednot
				last = j
				-- Match 1 or more path separators
				while j < len and isPathSeparator(stringPrototypeCharCodeAt(path, j)) do
					j = j + 1
				end
				if j < len and j ~= last then
					-- Matchednot
					last = j
					-- Match 1 or more non-path separators
					while j < len and not isPathSeparator(stringPrototypeCharCodeAt(path, j)) do
						j = j + 1
					end
					if j == len then
						-- We matched a UNC root only
						return path
					end
					if j ~= last then
						-- We matched a UNC root with leftovers

						-- Offset by 1 to include the separator after the UNC root to
						-- treat it as a "normal root" on top of a (UNC) root
						rootEnd = j + 1
						offset = j + 1
					end
				end
			end
		end
	elseif isWindowsDeviceRoot(code) and stringPrototypeCharCodeAt(path, 1) == CHAR_COLON then
		rootEnd = (len > 2 and isPathSeparator(stringPrototypeCharCodeAt(path, 2))) and 3 or 2
		offset = rootEnd
	end

	local endIndex = -1
	local matchedSlash = true
	for i = len - 1, offset, -1 do
		if isPathSeparator(stringPrototypeCharCodeAt(path, i)) then
			if not matchedSlash then
				endIndex = i
				break
			end
		else
			-- We saw the first non-path separator
			matchedSlash = false
		end
	end

	if endIndex == -1 then
		if rootEnd == -1 then
			return "."
		end
		endIndex = rootEnd
	end
	return stringPrototypeSlice(path, 0, endIndex)
end

function win32.basename(path, ext)
	if ext ~= nil then
		if type(path) ~= "string" then
			return nil, "Usage: basename(path, ext)"
		end
	end

	if type(path) ~= "string" then
		return nil, "Usage: basename(path, ext)"
	end

	local start = 0
	local endIndex = -1
	local matchedSlash = true

	-- Check for a drive letter prefix so as not to mistake the following
	-- path separator as an extra separator at the end of the path that can be
	-- disregarded
	if
		#path >= 2
		and isWindowsDeviceRoot(stringPrototypeCharCodeAt(path, 0))
		and stringPrototypeCharCodeAt(path, 1) == CHAR_COLON
	then
		-- skip the device root letter (if present)
		start = 2
	end

	if ext ~= nil and #ext > 0 and #ext <= #path then
		-- strip the extension (if one was given)
		if ext == path then
			return ""
		end

		local extIdx = #ext - 1
		local firstNonSlashEnd = -1
		for i = #path - 1, start, -1 do
			local code = stringPrototypeCharCodeAt(path, i)
			if isPathSeparator(code) then
				-- If we reached a path separator that was not part of a set of path
				-- separators at the end of the string, stop now
				if not matchedSlash then
					start = i + 1
					break
				end
			else
				if firstNonSlashEnd == -1 then
					-- We saw the first non-path separator, remember this index in case
					-- we need it if the extension ends up not matching
					matchedSlash = false
					firstNonSlashEnd = i + 1
				end
				if extIdx >= 0 then
					-- Try to match the explicit extension
					if code == stringPrototypeCharCodeAt(ext, extIdx) then
						extIdx = extIdx - 1
						if extIdx == -1 then
							-- We matched the extension, so mark this as the end of our path
							-- component
							endIndex = i
						end
					else
						-- Extension does not match, so our result is the entire path
						-- component
						extIdx = -1
						endIndex = firstNonSlashEnd
					end
				end
			end
		end

		if start == endIndex then
			endIndex = firstNonSlashEnd
		elseif endIndex == -1 then
			endIndex = #path
		end
		return stringPrototypeSlice(path, start, endIndex)
	end

	for i = #path - 1, start, -1 do
		if isPathSeparator(stringPrototypeCharCodeAt(path, i)) then
			-- If we reached a path separator that was not part of a set of path
			-- separators at the end of the string, stop now
			if not matchedSlash then
				start = i + 1
				break
			end
		elseif endIndex == -1 then
			-- We saw the first non-path separator, mark this as the end of our
			-- path component
			matchedSlash = false
			endIndex = i + 1
		end
	end

	if endIndex == -1 then
		return ""
	end

	return stringPrototypeSlice(path, start, endIndex)
end

function win32.extname(path)
	if type(path) ~= "string" then
		return nil, "Usage: extname(path)"
	end

	local start = 0
	local startDot = -1
	local startPart = 0
	local endIndex = -1
	local matchedSlash = true
	-- Track the state of characters (if any) we see before our first dot and
	-- after any path separator we find
	local preDotState = 0

	-- Check for a drive letter prefix so as not to mistake the following
	-- path separator as an extra separator at the end of the path that can be
	-- disregarded
	if
		#path >= 2
		and stringPrototypeCharCodeAt(path, 1) == CHAR_COLON
		and isWindowsDeviceRoot(stringPrototypeCharCodeAt(path, 0))
	then
		start = 2
		startPart = 2
	end

	local continue = false
	for i = #path - 1, start, -1 do
		local code = stringPrototypeCharCodeAt(path, i)

		if isPathSeparator(code) then
			-- If we reached a path separator that was not part of a set of path
			-- separators at the end of the string, stop now
			if not matchedSlash then
				startPart = i + 1
				break
			end
			continue = true
		end

		if not continue then
			if endIndex == -1 then
				-- We saw the first non-path separator, mark this as the end of our
				-- extension
				matchedSlash = false
				endIndex = i + 1
			end

			if code == CHAR_DOT then
				-- If this is our first dot, mark it as the start of our extension
				if startDot == -1 then
					startDot = i
				elseif preDotState ~= 1 then
					preDotState = 1
				end
			elseif startDot ~= -1 then
				-- We saw a non-dot and non-path separator before our dot, so we should
				-- have a good chance at having a non-empty extension
				preDotState = -1
			end
		end
		continue = false
	end

	if
		startDot == -1
		or endIndex == -1
		or preDotState == 0 -- We saw a non-dot character immediately before the dot
		or (preDotState == 1 and startDot == endIndex - 1 and startDot == startPart + 1)
	then -- The (right-most) trimmed path component is exactly '..'
		return ""
	end

	return stringPrototypeSlice(path, startDot, endIndex)
end

function posix.dirname(path)
	if type(path) ~= "string" then
		return nil, "Usage: dirname(path)"
	end

	if #path == 0 then
		return "."
	end

	local hasRoot = stringPrototypeCharCodeAt(path, 0) == CHAR_FORWARD_SLASH
	local endIndex = -1
	local matchedSlash = true

	for i = #path - 1, 1, -1 do
		if stringPrototypeCharCodeAt(path, i) == CHAR_FORWARD_SLASH then
			if not matchedSlash then
				endIndex = i
				break
			end
		else
			-- We saw the first non-path separator
			matchedSlash = false
		end
	end

	if endIndex == -1 then
		return hasRoot and "/" or "."
	end
	if hasRoot and endIndex == 1 then
		-- index 1 in js = 2nd character, offset by one due to Lua starting at index 1 (not 0)
		return "//"
	end
	return stringPrototypeSlice(path, 0, endIndex) -- remove the offset again because the wrapper fixes it interally before slicing?
end

function posix.basename(path, ext)
	if ext ~= nil then
		if type(ext) ~= "string" then
			return nil, "Usage: basename(path, ext)"
		end
	end

	if type(path) ~= "string" then
		return nil, "Usage: basename(path, ext)"
	end

	local start = 0
	local endIndex = -1
	local matchedSlash = true

	if ext ~= nil and #ext > 0 and #ext <= #path then
		if ext == path then
			return ""
		end
		local extIdx = #ext - 1
		local firstNonSlashEnd = -1
		for i = #path - 1, 0, -1 do
			local code = stringPrototypeCharCodeAt(path, i)
			if code == CHAR_FORWARD_SLASH then
				-- If we reached a path separator that was not part of a set of path
				-- separators at the end of the string, stop now
				if not matchedSlash then
					start = i + 1
					break
				end
			else
				if firstNonSlashEnd == -1 then
					-- We saw the first non-path separator, remember this index in case
					-- we need it if the extension ends up not matching
					matchedSlash = false
					firstNonSlashEnd = i + 1
				end
				if extIdx >= 0 then
					-- Try to match the explicit extension
					if code == stringPrototypeCharCodeAt(ext, extIdx) then
						extIdx = extIdx - 1
						if extIdx == -1 then
							-- We matched the extension, so mark this as the end of our path
							-- component
							endIndex = i
						end
					else
						-- Extension does not match, so our result is the entire path
						-- component
						extIdx = -1
						endIndex = firstNonSlashEnd
					end
				end
			end
		end

		if start == endIndex then
			endIndex = firstNonSlashEnd
		elseif endIndex == -1 then
			endIndex = #path
		end
		return stringPrototypeSlice(path, start, endIndex)
	end
	for i = #path - 1, 0, -1 do
		if stringPrototypeCharCodeAt(path, i) == CHAR_FORWARD_SLASH then
			-- If we reached a path separator that was not part of a set of path
			-- separators at the end of the string, stop now
			if not matchedSlash then
				start = i + 1
				break
			end
		elseif endIndex == -1 then
			-- We saw the first non-path separator, mark this as the end of our
			-- path component
			matchedSlash = false
			endIndex = i + 1
		end
	end

	if endIndex == -1 then
		return ""
	end
	return stringPrototypeSlice(path, start, endIndex)
end

function posix.isAbsolute(path)
	if type(path) ~= "string" then
		return nil, "Usage: isAbsolute(path)"
	end
	return #path > 0 and stringPrototypeCharCodeAt(path, 0) == CHAR_FORWARD_SLASH
end

function posix.normalize(path)
	if type(path) ~= "string" then
		return nil, "Usage: normalize(path)"
	end

	if #path == 0 then
		return "."
	end

	local isAbsolute = stringPrototypeCharCodeAt(path, 0) == CHAR_FORWARD_SLASH
	local trailingSeparator = stringPrototypeCharCodeAt(path, #path - 1) == CHAR_FORWARD_SLASH

	-- Normalize the path
	path = normalizeString(path, not isAbsolute, "/", isPosixPathSeparator)

	if #path == 0 then
		if isAbsolute then
			return "/"
		end
		return trailingSeparator and "./" or "."
	end
	if trailingSeparator then
		path = path .. "/"
	end

	return isAbsolute and format("/%s", path) or path
end

function posix.extname(path)
	if type(path) ~= "string" then
		return nil, "Usage: extname(path)"
	end

	local startDot = -1
	local startPart = 0
	local endIndex = -1
	local matchedSlash = true

	local continue = false
	-- Track the state of characters (if any) we see before our first dot and
	-- after any path separator we find
	local preDotState = 0
	for i = #path - 1, 0, -1 do
		local code = stringPrototypeCharCodeAt(path, i)
		if code == CHAR_FORWARD_SLASH then
			-- If we reached a path separator that was not part of a set of path
			-- separators at the end of the string, stop now
			if not matchedSlash then
				startPart = i + 1
				break
			end
			-- continue
			continue = true
		end

		if not continue then
			if endIndex == -1 then
				-- We saw the first non-path separator, mark this as the end of our
				-- extension
				matchedSlash = false
				endIndex = i + 1
			end

			if code == CHAR_DOT then
				-- If this is our first dot, mark it as the start of our extension
				if startDot == -1 then
					startDot = i
				elseif preDotState ~= 1 then
					preDotState = 1
				end
			elseif startDot ~= -1 then
				-- We saw a non-dot and non-path separator before our dot, so we should
				-- have a good chance at having a non-empty extension
				preDotState = -1
			end
		end

		continue = false
	end

	if
		startDot == -1
		or endIndex == -1 -- We saw a non-dot character immediately before the dot
		or preDotState == 0 -- The (right-most) trimmed path component is exactly '..'
		or (preDotState == 1 and startDot == endIndex - 1 and startDot == startPart + 1)
	then
		return ""
	end
	return stringPrototypeSlice(path, startDot, endIndex)
end

local function posixCwd()
	if ffi.os == "Windows" then
		-- Converts Windows' backslash path separators to POSIX forward slashes
		-- and truncates any drive indicator
		local pattern = "\\"

		local cwd = string_gsub(uv.cwd(), pattern, "/")
		local index = string_find(cwd, "/") -- We don't need the others, so discard all but the first
		return stringPrototypeSlice(cwd, index - 1)
	end

	-- We're already on POSIX, no need for any transformations
	return uv.cwd()
end

function posix.resolve(arg, ...)
	local args = { arg, ... }

	if not arg then
		return nil, "Usage: resolve(path1, [path2, ..., pathN])"
	end

	local resolvedPath = ""
	local resolvedAbsolute = false

	local continue = false
	local i = #args
	while i >= 0 and not resolvedAbsolute do
		local path = i >= 0 and args[i] or posixCwd()

		if type(path) ~= "string" then
			return nil, "Usage: extname(path)"
		end

		-- Skip empty entries
		if #path == 0 then
			continue = true
		end

		if not continue then
			resolvedPath = format("%s/%s", path, resolvedPath)
			resolvedAbsolute = stringPrototypeCharCodeAt(path, 0) == CHAR_FORWARD_SLASH
		end
		continue = false
		i = i - 1
	end

	-- At this point the path should be resolved to a full absolute path, but
	-- handle relative paths to be safe (might happen when uv.cwd() fails)

	-- Normalize the path
	resolvedPath = normalizeString(resolvedPath, not resolvedAbsolute, "/", isPosixPathSeparator)

	if resolvedAbsolute then
		return "/" .. resolvedPath
	end
	return #resolvedPath > 0 and resolvedPath or "."
end

function posix.join(...)
	local args = { ... }

	if #args == 0 then
		return "."
	end

	local joined
	for i = 1, #args, 1 do
		local arg = args[i]

		if type(arg) ~= "string" then
			return nil, "Usage: join(path1[, path2, path3, ..., pathN])"
		end

		if #arg > 0 then
			if joined == nil then
				joined = arg
			else
				joined = joined .. "/" .. arg
			end
		end
	end
	if joined == nil then
		return "."
	end

	return posix.normalize(joined)
end

function posix.relative(from, to)
	if type(from) ~= "string" then
		return nil, "Usage: relative(from, to)"
	end
	if type(to) ~= "string" then
		return nil, "Usage: relative(from, to)"
	end

	if from == to then
		return ""
	end

	-- Trim leading forward slashes.
	from = posix.resolve(from)
	to = posix.resolve(to)

	if from == to then
		return ""
	end

	local fromStart = 1
	local fromEnd = #from
	local fromLen = fromEnd - fromStart
	local toStart = 1
	local toLen = #to - toStart

	-- Compare paths to find the longest common path from root
	local length = (fromLen < toLen and fromLen or toLen)
	local lastCommonSep = -1
	local i = 0
	for l = 0, length, 1 do
		i = l
		local fromCode = stringPrototypeCharCodeAt(from, fromStart + l)
		if fromCode ~= stringPrototypeCharCodeAt(to, toStart + l) then
			break
		elseif fromCode == CHAR_FORWARD_SLASH then
			lastCommonSep = l
		end
	end

	if i == length then
		if toLen > length then
			if stringPrototypeCharCodeAt(to, toStart + i) == CHAR_FORWARD_SLASH then
				-- We get here if `from` is the exact base path for `to`.
				-- For example: from='/foo/bar' to='/foo/bar/baz'
				return stringPrototypeSlice(to, toStart + i + 1)
			end
			if i == 0 then
				-- We get here if `from` is the root
				-- For example: from='/' to='/foo'
				return stringPrototypeSlice(to, toStart + i)
			end
		elseif fromLen > length then
			if stringPrototypeCharCodeAt(from, fromStart + i) == CHAR_FORWARD_SLASH then
				-- We get here if `to` is the exact base path for `from`.
				-- For example: from='/foo/bar/baz' to='/foo/bar'
				lastCommonSep = i
			elseif i == 0 then
				-- We get here if `to` is the root.
				-- For example: from='/foo/bar' to='/'
				lastCommonSep = 0
			end
		end
	end

	local out = ""
	-- Generate the relative path based on the path difference between `to`
	-- and `from`.
	for index = fromStart + lastCommonSep + 1, fromEnd, 1 do
		if index == fromEnd or stringPrototypeCharCodeAt(from, index) == CHAR_FORWARD_SLASH then
			out = out .. (#out == 0 and ".." or "/..")
		end
	end

	-- Lastly, append the rest of the destination (`to`) path that comes after
	-- the common path parts.
	return out .. stringPrototypeSlice(to, toStart + lastCommonSep)
end

posix.win32 = win32
win32.win32 = win32
posix.posix = posix
win32.posix = posix

if ffi.os == "Windows" then
	return win32
else
	return posix
end
