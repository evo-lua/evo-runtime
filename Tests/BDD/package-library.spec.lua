describe("package", function()
	after(function()
		_G.foo = nil
		_G.bar = nil
	end)

	describe("open", function()
		it("should export all contained functions to the global environment", function()
			local someModule = {}
			function someModule:foo() end
			function someModule:bar() end

			package.open(someModule)

			assertEquals(_G.foo, someModule.foo)
			assertEquals(_G.bar, someModule.bar)
		end)

		it("should throw if it encounters a name clash", function()
			local someModule = {}
			function someModule:tonumber() end
			local backup = _G.tonumber

			assertThrows(function()
				package.open(someModule)
			end, "Cannot open package: Global tonumber is already defined")

			assertEquals(_G.tonumber, backup)
		end)
	end)
end)
