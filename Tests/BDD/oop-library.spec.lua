local oop = require("oop")

local function assertIsBaseClass(class, name)
	local mt = getmetatable(class)
	assertEquals(class.__name, name)
	assertEquals(mt.__index, class)
	assertEquals(type(class.Construct), "function")
	assertEquals(mt.__call, class.Construct)
end

describe("oop", function()
	describe("class", function()
		it("should return a prototype with a class name and constructor method added", function()
			local EmptyTippingJar = oop.class("EmptyTippingJar")
			assertIsBaseClass(EmptyTippingJar, "EmptyTippingJar")
		end)

		it("should assign a default constructor that can be used by derived classes as well", function()
			-- Regression: If the derived class defines no constructor, the default one will be used
			-- It should create an instance of the parent class and then extend it, instead of an empty table
			local ViolentMurderHobo = oop.class("ViolentMurderHobo")
			assertIsBaseClass(ViolentMurderHobo, "ViolentMurderHobo")
			ViolentMurderHobo.weapon = "none" -- Fallback that's always available to the derived class
			function ViolentMurderHobo:Construct()
				self.weapon = "fork" -- Should be assigned to derived class when this is called
			end

			local DangerousMethHead = oop.class("DangerousMethHead")
			oop.extend(DangerousMethHead, ViolentMurderHobo)
			local dmh = DangerousMethHead() -- Should call dmh.super.Construct in the default constructor
			assertEquals(dmh.weapon, "fork")
		end)

		it("should throw if no class name was passed", function()
			local expectedErrorMessage =
				"Expected argument classNameToRegister to be a string value, but received a nil value instead"
			assertThrows(function()
				oop.class(nil, nil)
			end, expectedErrorMessage)
		end)

		it("should throw if a registered class name was passed", function()
			assertThrows(function()
				oop.class("SharpDressedAlligator", nil)
				oop.class("SharpDressedAlligator", nil)
			end, format(oop.errorStrings.DUPLICATE_CLASS_NAME, "SharpDressedAlligator"))
		end)

		it("should return the given prototype with a class name and constructor method added", function()
			local LazyGovernmentOfficial = {
				speed = 0.001,
			}
			function LazyGovernmentOfficial:WorkHard()
				error("You probably won't ever see this")
			end

			local class = oop.class("LazyGovernmentOfficial", LazyGovernmentOfficial)
			assertIsBaseClass(LazyGovernmentOfficial, "LazyGovernmentOfficial")
			assertEquals(class.speed, LazyGovernmentOfficial.speed)
			assertEquals(class.WorkHard, LazyGovernmentOfficial.WorkHard)

			local instance = LazyGovernmentOfficial()
			assertEquals(instance.speed, LazyGovernmentOfficial.speed)
			assertEquals(instance.WorkHard, LazyGovernmentOfficial.WorkHard)
		end)

		it("should not override the prototype's existing constructor if one was defined", function()
			local EnragedDuckling = {}
			function EnragedDuckling:Construct()
				error("Quack!")
			end

			local class = oop.class("EnragedDuckling", EnragedDuckling)
			assertEquals(class.Construct, EnragedDuckling.Construct)
		end)
	end)

	describe("classname", function()
		it("should return nil if a regular Lua table was passed", function()
			local someTable = { hi = 42 }
			assertNil(oop.classname(someTable))
		end)

		it("should return the name of the prototype if an instance was passed", function()
			local RefactoringRustacean = oop.class("RefactoringRustacean")
			local instance = RefactoringRustacean()
			assertEquals(oop.classname(instance), "RefactoringRustacean")
		end)

		it("should throw if a non-table value was passed", function()
			local expectedErrorMessage =
				"Expected argument classOrInstance to be a table value, but received a number value instead"
			assertThrows(function()
				oop.classname(42)
			end, expectedErrorMessage)
		end)

		it("should return the name of the prototype if a prototype was passed", function()
			local class = oop.class("ScarySpider", {})
			assertEquals(oop.classname(class), "ScarySpider")
		end)

		it("should return nil if the class name was not registered using the oop library", function()
			local homebrewClass = {}
			setmetatable(homebrewClass, { __name = "HomebrewClass" })
			assertNil(oop.classname(homebrewClass))
		end)
	end)

	describe("instanceof", function()
		it("should throw if no instance to check was provided", function()
			local expectedErrorMessage =
				"Expected argument instance to be a table value, but received a nil value instead"
			assertThrows(function()
				oop.instanceof(nil, {})
			end, expectedErrorMessage)
		end)

		it("should throw if no prototype to check was provided", function()
			local expectedErrorMessage =
				"Expected argument instanceOrPrototype to be a table value, but received a nil value instead"
			assertThrows(function()
				oop.instanceof({}, nil)
			end, expectedErrorMessage)
		end)

		it("should return true if the provided instance is derived from the provided class prototype", function()
			local IllustriousScavengingDingbat = oop.class("IllustriousScavengingDingbat")
			local instance = IllustriousScavengingDingbat()
			assertTrue(oop.instanceof(instance, IllustriousScavengingDingbat))
			assertTrue(oop.instanceof(instance, "IllustriousScavengingDingbat"))
		end)

		it("should return true if the provided instance is the class prototype itself", function()
			local SuspiciouslyFuzzyCoconut = oop.class("SuspiciouslyFuzzyCoconut")
			assertTrue(oop.instanceof(SuspiciouslyFuzzyCoconut, SuspiciouslyFuzzyCoconut))
			assertTrue(oop.instanceof(SuspiciouslyFuzzyCoconut, "SuspiciouslyFuzzyCoconut"))
		end)

		it("should return false if the provided instance is not derived from the class prototype", function()
			local PerpetuallyBrokeStudent = oop.class("PerpetuallyBrokeStudent")
			local instanceA = PerpetuallyBrokeStudent()
			local WealthyBusinessMagnate = oop.class("WealthyBusinessMagnate")
			local instanceB = WealthyBusinessMagnate()

			assertFalse(oop.instanceof(instanceA, WealthyBusinessMagnate))
			assertFalse(oop.instanceof(instanceA, "WealthyBusinessMagnate"))
			assertFalse(oop.instanceof(instanceA, instanceB))

			assertFalse(oop.instanceof(instanceB, PerpetuallyBrokeStudent))
			assertFalse(oop.instanceof(instanceB, "PerpetuallyBrokeStudent"))
			assertFalse(oop.instanceof(instanceB, instanceA))
		end)
	end)

	describe("extend", function()
		it("should set up a metatable such that the child inherits the prototype's functionality", function()
			local CuriousInsectBreeder = oop.class("CuriousInsectBreeder")
			local ExasperatedSoccerMom = oop.class("ExasperatedSoccerMom")
			local child = CuriousInsectBreeder()
			local parent = ExasperatedSoccerMom()
			function parent:thisFunctionShouldBeInherited() end

			oop.extend(child, parent)
			assertEquals(child.thisFunctionShouldBeInherited, parent.thisFunctionShouldBeInherited)
		end)

		it("should set up metatables to enable inheritance chains", function()
			local FerociousCowbellRinger = oop.class("FerociousCowbellRinger")
			local OverworkedKindergartenTeacher = oop.class("OverworkedKindergartenTeacher")
			local RetiredMonsterRancher = oop.class("RetiredMonsterRancher")
			local child = FerociousCowbellRinger()
			local parent = OverworkedKindergartenTeacher()
			local grandparent = RetiredMonsterRancher()
			function parent:thisFunctionShouldBeInherited() end
			function grandparent:thisFunctionShouldAlsoBeInherited() end

			oop.extend(parent, grandparent)
			oop.extend(child, parent)

			assertEquals(child.thisFunctionShouldBeInherited, parent.thisFunctionShouldBeInherited)
			assertEquals(child.thisFunctionShouldAlsoBeInherited, grandparent.thisFunctionShouldAlsoBeInherited)
			assertEquals(parent.thisFunctionShouldAlsoBeInherited, grandparent.thisFunctionShouldAlsoBeInherited)
		end)

		it("should store a reference to the parent object to enable direct lookups", function()
			local StrangelyDiscoloredWater = oop.class("StrangelyDiscoloredWater")
			local SwarmOfLocusts = oop.class("SwarmOfLocusts")
			local ApocalypticHorseRider = oop.class("ApocalypticHorseRider")

			local child = StrangelyDiscoloredWater()
			local parent = SwarmOfLocusts()
			local grandparent = ApocalypticHorseRider()

			oop.extend(parent, grandparent)
			oop.extend(child, parent)

			assertEquals(child.super, parent)
			assertEquals(child.super.super, grandparent)
			assertEquals(parent.super, grandparent)
			assertNil(rawget(grandparent, "super"))
		end)
	end)

	describe("mixin", function()
		it("should throw if the target is not a table value", function()
			local expectedErrorMessage =
				"Expected argument target to be a table value, but received a number value instead"
			assertThrows(function()
				oop.mixin(42, {})
			end, expectedErrorMessage)
		end)

		it("should throw if any of the sources isn't a table value", function()
			local expectedErrorMessage =
				"Expected argument sourceObject3 to be a table value, but received a number value instead"
			assertThrows(function()
				oop.mixin({}, {}, {}, 42, {}, {})
			end, expectedErrorMessage)
		end)

		it("should throw if mixing in the sources would overwrite existing keys on the target", function()
			local target = { test1 = function() end }

			local sourceObject1 = { test1 = function() end }
			local sourceObject2 = { test2 = function() end }
			local expectedErrorMessage = format(oop.errorStrings.MIXIN_WOULD_OVERWRITE, "sourceObject1", "test1")
			assertThrows(function()
				oop.mixin(target, sourceObject1, sourceObject2)
			end, expectedErrorMessage)
		end)

		it("should mix in all values from the provided source tables", function()
			local target = {}
			local mixin1 = { test1 = function() end, hi = 42 }
			local mixin2 = { test2 = function() end }

			oop.mixin(target, mixin1, mixin2)

			assertEquals(target.test1, mixin1.test1)
			assertEquals(target.test2, mixin2.test2)
			assertEquals(target.hi, 42)
		end)
	end)

	describe("implements", function()
		it("should throw if an invalid class argument was passed", function()
			local expectedErrorMessage =
				"Expected argument instanceOrPrototype to be a table value, but received a number value instead"
			assertThrows(function()
				oop.implements(42, {})
			end, expectedErrorMessage)
		end)

		it("should throw if an invalid mixin argument was passed", function()
			local expectedErrorMessage =
				"Expected argument mixin to be a table value, but received a number value instead"
			assertThrows(function()
				oop.implements({}, 42)
			end, expectedErrorMessage)
		end)

		it("should return false if a class that doesn't include any mixins passed", function()
			local ClassWithoutMixins = oop.class("ClassWithoutMixins")
			assertFalse(oop.implements(ClassWithoutMixins, {}))
		end)

		it("should return whether a table includes the given mixin", function()
			local SomeClassLikeTable = {}
			local someMixin = { foo = 42 }
			local anotherMixin = { bar = "baz" }
			oop.mixin(SomeClassLikeTable, someMixin)
			assertTrue(oop.implements(SomeClassLikeTable, someMixin))
			assertFalse(oop.implements(SomeClassLikeTable, anotherMixin))
		end)

		it("should return whether a class includes the given mixin", function()
			local ClassWithDifferentMixinsA = oop.class("ClassWithDifferentMixinsA")
			local someMixin = { foo = 42 }
			local anotherMixin = { bar = "baz" }
			oop.mixin(ClassWithDifferentMixinsA, someMixin)
			assertTrue(oop.implements(ClassWithDifferentMixinsA, someMixin))
			assertFalse(oop.implements(ClassWithDifferentMixinsA, anotherMixin))
		end)

		it("should return whether an instance includes the given mixin", function()
			local ClassWithDifferentMixinsB = oop.class("ClassWithDifferentMixinsB")
			local someMixin = { foo = 42 }
			local anotherMixin = { bar = "baz" }
			oop.mixin(ClassWithDifferentMixinsB, anotherMixin)
			local instance = ClassWithDifferentMixinsB()
			assertTrue(oop.implements(instance, anotherMixin))
			assertFalse(oop.implements(instance, someMixin))
		end)
	end)
end)
