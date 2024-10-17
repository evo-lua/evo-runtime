local uv = require("uv")

-- local entryPoint = function(args)
		-- 	print("Entry point has been launched (in a background thread)")
		-- 	print(args)
		-- end
		local threadArgs = "TBD" -- Can not pass tables IIRC, nor other userdata? Review/document/test if that's needed
		-- local worker = uv.new_thread(entryPoint, threadArgs)
		local worker = uv.new_thread(function()
			print("Entry point has been launched (in a background thread)")
			-- print(arg) -- TODO not passed, by design?
			local uv = require("uv")
			print(uv)
		end, threadArgs)
		print("worker", worker)
		print(type(worker))
		-- TBD thread_self -- assert is different from worker thread
		-- TBD thread_join example
		-- TBD provide a way to preload libraries? footprint = heavy, maybe insecure, needs consideration/design/research into libuv codebase etc
		-- Assertion failed: !(handle->flags & UV_HANDLE_CLOSING), file libuv/src/win/async.c, line 76 <- that's probably the issue GZ mentioned in luv docs

		-- TODO join before test runner exits, else VM PANIC (see luv docs, limitation of the execution model)
			-- TBD PANIC: unprotected error in call to Lua API

		-- TODO check the error handling/limitations RE passing data across VM states here: https://github.com/luvit/luv/blob/master/tests/test-thread.lua