local uv = require("uv")

describe("uv", function()
	describe("get_process_title", function()
		it("should not fail with UV_ENOBUFS due to missing uv_setup_args", function()
			local processTitle, libuvErrorMessage = uv.get_process_title()
			assertEquals(type(processTitle), "string") -- Will be nil in case of failure
			assertNil(libuvErrorMessage) -- Will be ENOBUFFS if the argv memory wasn't set up
		end)
	end)

	describe("walk", function()
		it("should not crash when encountering foreign handles", function()
			uv.walk(function(handle)
				print(handle) -- Will crash before getting here if luv tries to process a foreign handle
			end)
		end)
	end)
end)
