local bit = require("bit")
local ffi = require("ffi")

local tonumber = tonumber

local cpp = {}

cpp.cdefs = [[

struct static_cpp_exports_table {
	// Numerics library
	size_t (*bit_ceil)(size_t n);
	size_t (*bit_floor)(size_t n);
	int (*bit_width)(size_t n);
	bool (*has_single_bit)(size_t n);
};

]]

function cpp.initialize()
	ffi.cdef(cpp.cdefs)

	bit.ceil = cpp.getNextPowerOfTwo
	bit.floor = cpp.getLastPowerOfTwo
	bit.ispow2 = cpp.isPowerOfTwo
	bit.width = cpp.getBitLength
end

function cpp.getNextPowerOfTwo(n)
	return tonumber(cpp.bindings.bit_ceil(n))
end

function cpp.getLastPowerOfTwo(n)
	return tonumber(cpp.bindings.bit_floor(n))
end

function cpp.isPowerOfTwo(n)
	return cpp.bindings.has_single_bit(n)
end

function cpp.getBitLength(n)
	return tonumber(cpp.bindings.bit_width(n))
end

return cpp
