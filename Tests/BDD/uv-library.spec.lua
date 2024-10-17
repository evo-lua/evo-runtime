local uv = require("uv")

describe("uv", function()
	describe("get_process_title", function()
		it("should not fail with UV_ENOBUFS due to missing uv_setup_args", function()
			local processTitle, libuvErrorMessage = uv.get_process_title()
			assertEquals(type(processTitle), "string") -- Will be nil in case of failure
			assertNil(libuvErrorMessage) -- Will be ENOBUFFS if the argv memory wasn't set up
		end)
	end)
	describe("new_thread", function()
		-- should not crash if the main thread exits first (luv docs, review note)
		-- TBD what if stack size is HUGE? or small/negative? check luv tests/src
		local entryPoint = function(args)
			print("Entry point has been launched (in a background thread)")
			print(args)
		end
		local threadArgs = "TBD" -- Can not pass tables IIRC, nor other userdata? Review/document/test if that's needed
		-- local worker = uv.new_thread(entryPoint, threadArgs)
		local worker = uv.new_thread(function()
			print("Entry point has been launched (in a background thread)")
			print(args)
		end, threadArgs)
		print("worker", worker)
		print(type(worker))
		-- TBD PANIC: unprotected error in call to Lua API (?)
		-- TBD thread_self -- assert is different from worker thread
		-- TBD thread_join example
		-- TBD provide a way to preload libraries? footprint = heavy, maybe insecure, needs consideration/design/research into NodeJS etc
		-- Assertion failed: !(handle->flags & UV_HANDLE_CLOSING), file libuv/src/win/async.c, line 76
	end)
end)
