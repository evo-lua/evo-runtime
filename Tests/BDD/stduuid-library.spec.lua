local ffi = require("ffi")
local stduuid = require("stduuid")

local UUID_PATTERN = "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"

describe("stduuid", function()
	describe("bindings", function()
		it("should export the entirety of the stduuid API", function()
			local exportedApiSurface = {
				"uuid_create_v4",
				"uuid_create_mt19937",
				"uuid_create_v5",
				"uuid_create_system",
			}

			for _, functionName in ipairs(exportedApiSurface) do
				assertEquals(type(stduuid.bindings[functionName]), "cdata")
			end
		end)

		describe("uuid_create_v4", function()
			it("should generate a UUID string in the expected format", function()
				local guid = ffi.new("uuid_rfc_string_t")
				local guidPointer = ffi.cast("char (*)[37]", guid)

				stduuid.bindings.uuid_create_v4(guidPointer)
				guid = ffi.string(guid)

				local isValidUUID = string.match(guid, UUID_PATTERN) ~= nil
				assertTrue(isValidUUID)
			end)
		end)

		describe("uuid_create_mt19937", function()
			it("should generate a UUID string in the expected format", function()
				local guid = ffi.new("uuid_rfc_string_t")
				local guidPointer = ffi.cast("char (*)[37]", guid)

				stduuid.bindings.uuid_create_mt19937(guidPointer)
				guid = ffi.string(guid)

				local isValidUUID = string.match(guid, UUID_PATTERN) ~= nil
				assertTrue(isValidUUID)
			end)
		end)

		describe("uuid_create_v5", function()
			it("should generate a UUID string in the expected format", function()
				local namespace = "47183823-2574-4bfd-b411-99ed177d3e43"
				local name = "john"
				local expectedGUID = "0dbbd6be-b274-536b-b356-c22d8ea30a0e"

				local guid = ffi.new("uuid_rfc_string_t")
				local guidPointer = ffi.cast("char (*)[37]", guid)

				stduuid.bindings.uuid_create_v5(namespace, name, guidPointer)
				guid = ffi.string(guid)

				local isValidUUID = string.match(guid, UUID_PATTERN) ~= nil
				assertTrue(isValidUUID)
				assertEquals(guid, expectedGUID)
			end)
		end)

		describe("uuid_create_system", function()
			it("should generate a UUID string in the expected format", function()
				local guid = ffi.new("uuid_rfc_string_t")
				local guidPointer = ffi.cast("char (*)[37]", guid)

				stduuid.bindings.uuid_create_system(guidPointer)
				guid = ffi.string(guid)

				local isValidUUID = string.match(guid, UUID_PATTERN) ~= nil
				assertTrue(isValidUUID)
			end)
		end)
	end)

	describe("version", function()
		it("should be a semantic version string", function()
			local versionString = stduuid.version()
			local major, minor, patch = string.match(versionString, "(%d+).(%d+).(%d+)")

			assertEquals(type(major), "string")
			assertEquals(type(minor), "string")
			assertEquals(type(patch), "string")
		end)
	end)
end)
