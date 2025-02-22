local ffi = require("ffi")
local vmdef = require("vmdef")

local function table_find(where, what)
	for key, value in pairs(where) do
		if value == what then
			return key
		end
	end
end

describe("debug", function()
	describe("sbuf", function()
		it("should return a human-readable representation if an empty buffer was passed", function()
			local sbuf = buffer.new(0)
			local str = debug.sbuf(sbuf)
			assertEquals(str, "Buffer []")
		end)

		it("should return a human-readable representation if a non-empty buffer was passed", function()
			local sbuf = buffer.new(42):put("Hello world")
			local str = debug.sbuf(sbuf)
			assertEquals(str, "Buffer [48, 65, 6C, 6C, 6F, 20, 77, 6F, 72, 6C, 64]")
		end)

		it("should gracefully handle non-buffer userdata values", function()
			local temporaryFileHandle = io.open("README.md", "r")
			assertEquals(type(temporaryFileHandle), "userdata")
			assertEquals(debug.sbuf(temporaryFileHandle), tostring(temporaryFileHandle))
			temporaryFileHandle:close()
		end)
	end)

	describe("tostring", function()
		it("should translate VM builtins to human-readable names", function()
			local arbitraryBuiltinFunction = ffi.gc
			local builtinID = assert(table_find(vmdef.ffnames, "ffi.gc"))

			local defaultName = tostring(arbitraryBuiltinFunction)
			local expectedDefaultName = "function: builtin#" .. builtinID
			assertEquals(defaultName, expectedDefaultName)

			local debugName = debug.tostring(arbitraryBuiltinFunction)
			local expectedDebugName = "function: ffi.gc"
			assertEquals(debugName, expectedDebugName)
		end)
	end)
end)
