local uv = require("uv")

local jit = require("jit")
print(jit.version_num)
-- jit.off()

-- collectgarbage("stop")

local handle
handle = uv.fs_open("does-not-exist", "r", 438, function(err, fd) -- TODO req not handle
	print(err, fd)
	print(type(handle))
	-- print(handle)
	-- error("this is never executed")
end)

print(type(handle))
print(handle)

-- uv.run()

print("uv.walk", uv.walk)
print("uv.__walk", uv.__walk)

uv.walk(function(_)
	print(_)
	-- print(_) -- uv_close: Assertion `!uv__is_closing(handle)' faile
	-- error("this is never executed either")
end)

-- uv.run()