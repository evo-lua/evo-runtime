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
			local AttackHelicopter = oop.class("AttackHelicopter")

			local didCallInheritedMethod = false
			function AttackHelicopter:DoSomething()
				didCallInheritedMethod = true
			end

			local someObject = oop.new(AttackHelicopter) -- AttackHelicopter.Construct
			someObject:DoSomething()
			assertTrue(didCallInheritedMethod)
		end)
		
		it("should store the given class name in the class object", function()
			local AttackHelicopter = oop.class("AttackHelicopter")

			assertEquals(AttackHelicopter.name, "AttackHelicopter")
			instance = AttackHelicopter:new()
			assertEquals(instance.class.name, "AttackHelicopter")
			instance = oop.new(AttackHelicopter)
			assertEquals(instance.class.name, "AttackHelicopter")
			instance = AttackHelicopter()
			assertEquals(instance.class.name, "AttackHelicopter")
			-- assertEquals(AttackHelicopter().name, ">")
			-- local didCallConstructor = false
			-- function AttackHelicopter:Construct()
			-- 	didCallConstructor = true
			-- 	local instance = {}
			-- 	setmetatable(instance, self)
			-- 	return instance
			-- end
			

			-- local didCallInheritedMethod = false
			-- function AttackHelicopter:DoSomething()
			-- 	didCallInheritedMethod = true
			-- end

			-- local someObject = AttackHelicopter()
			-- dump(someObject)
			-- someObject:DoSomething()
			-- assertTrue(didCallConstructor)
			-- assertTrue(didCallInheritedMethod)
		end)
	end)
end)