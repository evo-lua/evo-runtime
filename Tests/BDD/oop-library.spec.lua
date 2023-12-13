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
			local FlyingSpaghettiMonster = oop.class("FlyingSpaghettiMonster")

			local didCallInheritedMethod = false
			function FlyingSpaghettiMonster:DoSomething()
				didCallInheritedMethod = true
			end

			local someObject = oop.new(FlyingSpaghettiMonster) -- FlyingSpaghettiMonster.Construct
			someObject:DoSomething()
			assertTrue(didCallInheritedMethod)
		end)
		
		it("should store the given class name in the class object", function()
			local FlyingSpaghettiMonster = oop.class("FlyingSpaghettiMonster")

			assertEquals(FlyingSpaghettiMonster.name, "FlyingSpaghettiMonster")
			instance = FlyingSpaghettiMonster:new()
			assertEquals(instance.class.name, "FlyingSpaghettiMonster")
			instance = oop.new(FlyingSpaghettiMonster)
			assertEquals(instance.class.name, "FlyingSpaghettiMonster")
			instance = FlyingSpaghettiMonster()
			assertEquals(instance.class.name, "FlyingSpaghettiMonster")
			-- assertEquals(FlyingSpaghettiMonster().name, ">")
			-- local didCallConstructor = false
			-- function FlyingSpaghettiMonster:Construct()
			-- 	didCallConstructor = true
			-- 	local instance = {}
			-- 	setmetatable(instance, self)
			-- 	return instance
			-- end
			

			-- local didCallInheritedMethod = false
			-- function FlyingSpaghettiMonster:DoSomething()
			-- 	didCallInheritedMethod = true
			-- end

			-- local someObject = FlyingSpaghettiMonster()
			-- dump(someObject)
			-- someObject:DoSomething()
			-- assertTrue(didCallConstructor)
			-- assertTrue(didCallInheritedMethod)
		end)
	end)
end)