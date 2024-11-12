local uv = require("uv")

describe("uv", function()
	describe("get_process_title", function()
		it("should not fail with UV_ENOBUFS due to missing uv_setup_args", function()
			local processTitle, libuvErrorMessage = uv.get_process_title()
			assertEquals(type(processTitle), "string") -- Will be nil in case of failure
			assertNil(libuvErrorMessage) -- Will be ENOBUFFS if the argv memory wasn't set up
		end)
	end)

	describe("fs_open", function()
		it("should not crash", function()
			local handle
			handle = uv.fs_open("LICENSE", "r", 438, function(err, fd)
				print(err, fd)
				-- print(type(handle))
				-- print(handle)
				-- error("this is never executed")
			end)

			print(type(handle))
			print(handle)
			uv.run()
			uv.walk(function(_)
				-- error("this is never executed either")
			end)
		end)
	end)
end)
