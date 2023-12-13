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
		it("should return a class definitiont that can be used to instantiate objects", function()
			local TestClass1 = oop.class("TestClass1")

			local didCallInheritedMethod = false
			function TestClass1:DoSomething()
				didCallInheritedMethod = true
			end

			local someObject = oop.new(TestClass1)
			someObject:DoSomething()
			assertTrue(didCallInheritedMethod)
		end)

		it("should store the given class name in the class object", function()
			local TestClass2 = oop.class("TestClass2")

			local instance = TestClass2()
			assertEquals(instance.class.name, "TestClass2")
			instance = TestClass2:new()
			assertEquals(instance.class.name, "TestClass2")
			instance = oop.new(TestClass2)
			assertEquals(instance.class.name, "TestClass2")
		end)

		it("should throw if a class with the given name has already been registered", function()
			oop.class("TestClass3")
			assertThrows(function()
				oop.class("TestClass3")
			end, "Failed to register class TestClass3 (a class with this name already exists)")
		end)
	end)

	describe("new", function()
		it("should allow each created instance to access class variables", function()
			local TestClass4 = oop.class("TestClass4")
			TestClass4.SOME_CONSTANT_VALUE = 1234
			local instance = oop.new(TestClass4)

			assertEquals(instance.SOME_CONSTANT_VALUE, 1234)
		end)

		it("should allow each created instance to access instance variables independently", function()
			local TestClass5 = oop.class("TestClass5")

			local instanceA = oop.new(TestClass5)
			instanceA.foo = 12345
			local instanceB = oop.new(TestClass5)
			instanceB.foo = 54321

			assertEquals(instanceA.foo, 12345)
			assertEquals(instanceB.foo, 54321)
		end)

		it("should invoke the constructor if one was created", function()
			local TestClass6 = oop.class("TestClass6")

			function TestClass6:initialize()
				self.foo = 42
			end

			-- function FerociousKillerRabbit:Construct()
			-- 	self.foo = 44
			-- end

			local instance = oop.new(TestClass6)

			-- assertEquals(FerociousKillerRabbit.foo, 42)
			assertEquals(instance.foo, 42)
			-- assertEquals(instance.foo, 44)
		end)

		it("should invoke the standard constructor if one was created", function()
			local TestClass7 = oop.class("TestClass7")

			function TestClass7:initialize()
				self.foo = 42
			end

			function TestClass7:Construct()
				self.foo = 44
			end

			local instance = oop.new(TestClass7)
			-- instance = TestClass7()

			-- assertEquals(FerociousKillerRabbit.foo, 42)
			-- assertEquals(instance.foo, 42)
			assertEquals(instance.foo, 44)
		end)

		it("should invoke the fallback constructor if none was created", function()
			local TestClass8 = oop.class("TestClass8")

			function TestClass8:initialize()
				self.foo = 42
			end

			-- function TestClass7:Construct()
			-- 	self.foo = 44
			-- end

			local instance = oop.new(TestClass8)
			-- instance = TestClass7()

			-- assertEquals(FerociousKillerRabbit.foo, 42)
			assertEquals(instance.foo, 42)
			-- assertEquals(instance.foo, 44)
		end)

		-- it("should set up the instance metatable so that accessing nonexistent fields throws", function()
		-- 	local TestClass8 = oop.class("TestClass8")
		-- 	local instance = TestClass8()
		-- 	assertThrows(function()
		-- 		instance.foo = 42
		-- 		local foo = instance.bar
		-- 	end, "???")
		-- end)
	end)
end)
