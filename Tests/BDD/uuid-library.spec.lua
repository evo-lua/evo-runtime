local uuid = require("uuid")

local UUID_PATTERN = "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$"

describe("uuid", function()
	it("should export the RFC UUID string pattern as a constant", function()
		assertEquals(uuid.RFC_STRING_PATTERN, UUID_PATTERN)
	end)

	describe("create_v4", function()
		it("should generate a UUID string in the expected format", function()
			local guid = uuid.create_v4()

			local isValidUUID = string.match(guid, UUID_PATTERN) ~= nil
			assertTrue(isValidUUID)
		end)
	end)

	describe("create_mersenne_twisted", function()
		it("should generate a UUID string in the expected format", function()
			local guid = uuid.create_mersenne_twisted()

			local isValidUUID = string.match(guid, UUID_PATTERN) ~= nil
			assertTrue(isValidUUID)
		end)
	end)

	describe("create_v5", function()
		it("should generate a UUID string in the expected format", function()
			local namespace = "47183823-2574-4bfd-b411-99ed177d3e43"
			local name = "john"
			local expectedGUID = "0dbbd6be-b274-536b-b356-c22d8ea30a0e"

			local guid = uuid.create_v5(namespace, name)

			local isValidUUID = string.match(guid, UUID_PATTERN) ~= nil
			assertTrue(isValidUUID)
			assertEquals(guid, expectedGUID)
		end)

		it("should throw if an invalid namespace is passed", function()
			assertThrows(function()
				uuid.create_v5(nil, "test")
			end, "Expected argument namespace to be a string value, but received a nil value instead")
		end)

		it("should throw if an invalid name is passed", function()
			assertThrows(function()
				uuid.create_v5("47183823-2574-4bfd-b411-99ed177d3e43", nil)
			end, "Expected argument name to be a string value, but received a nil value instead")
		end)

		it("should throw if the namespace passed is not a valid RFC UUID", function()
			assertThrows(function()
				uuid.create_v5("47183823-2574-4bfd-b411-99ed177d3e43xxx", "test123")
			end, "Expected argument namespace to be a valid RFC UUID string")
		end)
	end)

	describe("create_system_guid", function()
		it("should generate a UUID string in the expected format", function()
			local guid = uuid.create_system_guid()

			local isValidUUID = string.match(guid, UUID_PATTERN) ~= nil
			assertTrue(isValidUUID)
		end)
	end)

	describe("is_valid", function()
		it("should return false if an invalid type is passed", function()
			local isValidUUID = uuid.is_valid(42)
			assertFalse(isValidUUID)
		end)

		it("should return false if the value passed is not a valid RFC UUID", function()
			local isValidUUID = uuid.is_valid("47183823-2574-4bfd-b411-99ed177d3e43xxx")
			assertFalse(isValidUUID)
		end)
		it("should return true if the value passed is a valid RFC UUID", function()
			local isValidUUID = uuid.is_valid("47183823-2574-4bfd-b411-99ed177d3e43")
			assertTrue(isValidUUID)
		end)
	end)
end)
