local oop = require("oop")

describe("oop", function()
	describe("version", function()
		it("hould return a semantic version string", function()
			local versionString = oop.version()
			local major, minor, patch = string.match(versionString, "(%d+).(%d+).(%d+)")

			assertEquals(type(major), "string")
			assertEquals(type(minor), "string")
			assertEquals(type(patch), "string")
		end)
	end)

	describe("class", function()
		it("should return ", function()
			local MyClass = oop.class("MyClass")

			local didCallInheritedMethod = false
			function MyClass:DoSomething()
				didCallInheritedMethod = true
			end

			local someObject = oop.new(MyClass) -- MyClass.Construct
			someObject:DoSomething()
			assertTrue(didCallInheritedMethod)
		end)
	end)
end)