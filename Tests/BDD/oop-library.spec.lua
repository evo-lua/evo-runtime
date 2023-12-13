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

		it("should throw if a class with the given name has already been registered", function()
			local MyClass = oop.class("MyClass")
			assertThrows(function()
				oop.class("MyClass")
			end, "Failed to register class MyClass (a class with this name already exists")
		end)
	end)
	describe("new", function()
		it("should allow each created instance to access class variables", function()
			local FerociousKillerRabbit = oop.class("FerociousKillerRabbit")
			FerociousKillerRabbit.SOME_CONSTANT_VALUE = 1234
			local 			instance = oop.new(FerociousKillerRabbit)

			assertEquals(instance.SOME_CONSTANT_VALUE, 1234)
		end)

		it("should allow each created instance to access instance variables independently", function()
			local FerociousKillerRabbit = oop.class("FerociousKillerRabbit")
			
			local instanceA = oop.new(FerociousKillerRabbit)
			instanceA.foo = 12345
			local instanceB = oop.new(FerociousKillerRabbit)
			instanceB.foo = 54321

			assertEquals(instanceA.foo, 12345)
			assertEquals(instanceB.foo, 54321)
		end)

		it("should invoke the constructor if one was created", function()
			local FerociousKillerRabbit = oop.class("FerociousKillerRabbit")

			function FerociousKillerRabbit:initialize()
				self.foo = 42
			end

			-- function FerociousKillerRabbit:Construct()
			-- 	self.foo = 44
			-- end

			instance = oop.new(FerociousKillerRabbit)


			-- assertEquals(FerociousKillerRabbit.foo, 42)
			assertEquals(instance.foo, 42)
			-- assertEquals(instance.foo, 44)
		end)

		it("should invoke the constructor if one was created", function()
			local FerociousKillerRabbit = oop.class("FerociousKillerRabbit")

			-- function FerociousKillerRabbit:initialize()
			-- 	self.foo = 42
			-- end

			function FerociousKillerRabbit:Construct()
				self.foo = 44
			end

			-- instance = oop.new(FerociousKillerRabbit)
			instance = FerociousKillerRabbit()


			-- assertEquals(FerociousKillerRabbit.foo, 42)
			-- assertEquals(instance.foo, 42)
			assertEquals(instance.foo, 44)
		end)
	end)
end)