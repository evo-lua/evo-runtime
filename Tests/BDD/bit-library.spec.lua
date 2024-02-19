local bit = require("bit")

describe("bit", function()
	describe("ceil", function()
		it("should round up to the next power-of-two number larger than the provided number", function()
			assertEquals(bit.ceil(0), 1)
			assertEquals(bit.ceil(1), 1)
			assertEquals(bit.ceil(2), 2)
			assertEquals(bit.ceil(3), 4)
			assertEquals(bit.ceil(4), 4)
			assertEquals(bit.ceil(1023), 1024)
			assertEquals(bit.ceil(1025), 2048)
		end)
	end)

	describe("floor", function()
		it("should round down to the last power-of-two number smaller than the provided number", function()
			assertEquals(bit.floor(0), 0)
			assertEquals(bit.floor(1), 1)
			assertEquals(bit.floor(2), 2)
			assertEquals(bit.floor(3), 2)
			assertEquals(bit.floor(4), 4)
			assertEquals(bit.floor(1025), 1024)
		end)
	end)

	describe("width", function()
		it("should return the number of bits required to represent the provided number", function()
			assertEquals(bit.width(0), 0)
			assertEquals(bit.width(1), 1)
			assertEquals(bit.width(2), 2)
			assertEquals(bit.width(3), 2)
			assertEquals(bit.width(4), 3)
			assertEquals(bit.width(1024), 11)
		end)
	end)

	describe("ispow2", function()
		it("should return true if the provided number has a single bit", function()
			assertTrue(bit.ispow2(2))
			assertTrue(bit.ispow2(4))
			assertTrue(bit.ispow2(8))
			assertTrue(bit.ispow2(16))
			assertTrue(bit.ispow2(32))
			assertTrue(bit.ispow2(64))
			assertTrue(bit.ispow2(128))
			assertTrue(bit.ispow2(256))
			assertTrue(bit.ispow2(512))
			assertTrue(bit.ispow2(1024))
			assertTrue(bit.ispow2(2048))
			assertTrue(bit.ispow2(4096))
			assertTrue(bit.ispow2(8192))
		end)

		it("should return false if the provided number has zero bits", function()
			assertFalse(bit.ispow2(0))
		end)

		it("should return false if the provided number has multiple bits", function()
			assertFalse(bit.ispow2(3))
			assertFalse(bit.ispow2(5))
			assertFalse(bit.ispow2(6))
			assertFalse(bit.ispow2(7))
			assertFalse(bit.ispow2(9))
			assertFalse(bit.ispow2(10))
			assertFalse(bit.ispow2(11))
			assertFalse(bit.ispow2(12))
			assertFalse(bit.ispow2(13))
			assertFalse(bit.ispow2(14))
			assertFalse(bit.ispow2(15))
		end)
	end)
end)
