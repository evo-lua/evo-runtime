local ffi = require("ffi")
local stduuid = require("stduuid")
local validation = require("validation")

local type = type
local ffi_cast = ffi.cast
local ffi_new = ffi.new
local ffi_string = ffi.string
local string_match = string.match
local validateString = validation.validateString

local uuid = {
	RFC_STRING_PATTERN = "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$",
}

function uuid.create_v4()
	local guid = ffi_new("uuid_rfc_string_t")
	local guidPointer = ffi_cast("uuid_rfc_string_t*", guid)

	stduuid.bindings.uuid_create_v4(guidPointer)
	guid = ffi_string(guid)

	return guid
end

function uuid.create_mersenne_twisted()
	local guid = ffi_new("uuid_rfc_string_t")
	local guidPointer = ffi_cast("uuid_rfc_string_t*", guid)

	stduuid.bindings.uuid_create_mt19937(guidPointer)
	guid = ffi_string(guid)

	return guid
end

function uuid.create_v5(namespace, name)
	validateString(namespace, "namespace")
	validateString(name, "name")

	if not uuid.is_valid(namespace) then
		error("Expected argument namespace to be a valid RFC UUID string", 0)
	end

	local guid = ffi_new("uuid_rfc_string_t")
	local guidPointer = ffi_cast("uuid_rfc_string_t*", guid)

	stduuid.bindings.uuid_create_v5(namespace, name, guidPointer)
	guid = ffi_string(guid)

	return guid
end

function uuid.create_system_guid()
	local guid = ffi_new("uuid_rfc_string_t")
	local guidPointer = ffi_cast("uuid_rfc_string_t*", guid)

	stduuid.bindings.uuid_create_system(guidPointer)
	guid = ffi_string(guid)

	return guid
end

function uuid.is_valid(input)
	if type(input) ~= "string" then
		return false
	end

	return string_match(input, uuid.RFC_STRING_PATTERN) ~= nil
end

return uuid
