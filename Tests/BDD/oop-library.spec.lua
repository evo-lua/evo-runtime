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
			local FerociousKillerRabbit = oop.class("FerociousKillerRabbit")

			local didCallInheritedMethod = false
			function FerociousKillerRabbit:DoSomething()
				didCallInheritedMethod = true
			end

			local someObject = oop.new(FerociousKillerRabbit) -- FerociousKillerRabbit.Construct
			someObject:DoSomething()
			assertTrue(didCallInheritedMethod)
		end)
		
		it("should store the given class name in the class object", function()
			local FerociousKillerRabbit = oop.class("FerociousKillerRabbit")

			local instance = FerociousKillerRabbit()


			instance = FerociousKillerRabbit:new()
			assertEquals(instance.class.name, "FerociousKillerRabbit")
			instance = oop.new(FerociousKillerRabbit)
			assertEquals(instance.class.name, "FerociousKillerRabbit")
			instance = FerociousKillerRabbit()
			assertEquals(instance.class.name, "FerociousKillerRabbit")
		end)
	end)
	describe("new", function()
	
		it("should execute the constructor if one was created", function()
			local FerociousKillerRabbit = oop.class("FerociousKillerRabbit")
			function FerociousKillerRabbit:initialize()
				self.foo = 42
			end

			instance = oop.new(FerociousKillerRabbit)


			assertEquals(instance.foo, 42)
		end)
	end)
end)