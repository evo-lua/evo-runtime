-- Adapted from the v8 runtime implementation of String.prototype.lastIndexOf
-- from https://github.com/v8/v8/blob/901b67916dc2626158f42af5b5c520ede8752da2/src/runtime/runtime-strings.cc

-- Copyright 2014, the v8 project authors. All rights reserved.
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are
-- met:

--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above
--       copyright notice, this list of conditions and the following
--       disclaimer in the documentation and/or other materials provided
--       with the distribution.
--     * Neither the name of Google Inc. nor the names of its
--       contributors may be used to endorse or promote products derived
--       from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
-- "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
-- A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
-- OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
-- LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
-- DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
-- THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- These primitives use JavaScript conventions (indices start at zero) and are only used for the ported JS code (NodeJS API)
local v8 = {}

-- Upvalues
local string_sub = string.sub
local assert = assert
local tonumber = tonumber
local tostring = tostring
local type = type

function v8.stringMatchBackwards(subject, pattern, idx)
	local pattern_length = #pattern
	local pattern_first_char = string_sub(pattern, 1, 1)
	for i = idx, 0, -1 do
		local characterToCheck = string_sub(subject, i + 1, i + 1)
		if characterToCheck == pattern_first_char then
			-- Check the rest of the pattern
			local j = 1
			while j < pattern_length do
				if string_sub(pattern, j + 1, j + 1) ~= string_sub(subject, i + j + 1, i + j + 1) then
					break
				end

				j = j + 1
			end

			if j == pattern_length then
				return i
			end
		end
	end

	return -1
end

function v8.stringLastIndexOf(sub, pat, index)
	assert(sub ~= nil, "Usage: stringLastIndexOf(sub, pat, index)")
	assert(pat ~= nil, "Usage: stringLastIndexOf(sub, pat, index)")
	assert(index ~= nil, "Usage: stringLastIndexOf(sub, pat, index)")

	sub = tostring(sub)
	pat = tostring(pat)
	index = tonumber(index)
	assert(type(sub) == "string", "stringLastIndexOf: Argument sub is not a string")
	assert(type(pat) == "string", "stringLastIndexOf: Argument pat is not a string")
	assert(type(index) == "number", "stringLastIndexOf: Argument index is not a number")

	local start_index = index

	local pat_length = #pat
	local sub_length = #sub

	if start_index + pat_length > sub_length then
		start_index = sub_length - pat_length
	end

	if pat_length == 0 then
		return start_index
	end

	local position
	position = v8.stringMatchBackwards(sub, pat, start_index)
	return position
end

function v8.stringPrototypeLastIndexOf(sub, pat, position)
	sub = tostring(sub)
	local subLength = #sub
	pat = tostring(pat)
	local patLength = #pat
	local index = subLength - patLength

	local argc = 0
	if sub ~= nil then
		argc = argc + 1
	end
	if pat ~= nil then
		argc = argc + 1
	end
	if index ~= nil then
		argc = argc + 1
	end

	if argc > 1 then
		position = tonumber(position)
		if position ~= nil then
			position = tonumber(position)
			if position < 0 then
				position = 0
			end

			if position + patLength < subLength then
				index = position
			end
		end
	end

	if index < 0 then
		return -1
	end

	return v8.stringLastIndexOf(sub, pat, index)
end

return v8
