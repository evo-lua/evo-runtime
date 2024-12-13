local git = require("git")

describe("git", function()
	describe("modules", function()
		local fileContents = [[
[submodule "deps/LuaJIT/LuaJIT"]
path = deps/LuaJIT/LuaJIT
url = https://github.com/LuaJIT/LuaJIT
ignore = dirty
branch = v2.1
[submodule "deps/openssl/openssl"]
	path = deps/openssl/openssl
	url = https://github.com/openssl/openssl
	ignore = dirty
	branch = master
	fetchRecurseSubmodules = false
	shallow = true
	update = checkout
]]

		it("should return a table representing the .gitmodule file contents", function()
			local submodules = git.modules(fileContents)
			assertEquals(table.count(submodules), 2)

			assertEquals(submodules["deps/LuaJIT/LuaJIT"].path, "deps/LuaJIT/LuaJIT")
			assertEquals(submodules["deps/LuaJIT/LuaJIT"].url, "https://github.com/LuaJIT/LuaJIT")
			assertEquals(submodules["deps/LuaJIT/LuaJIT"].ignore, "dirty")

			assertEquals(submodules["deps/openssl/openssl"].path, "deps/openssl/openssl")
			assertEquals(submodules["deps/openssl/openssl"].url, "https://github.com/openssl/openssl")
			assertEquals(submodules["deps/openssl/openssl"].ignore, "dirty")
			assertEquals(submodules["deps/openssl/openssl"].branch, "master")
			assertEquals(submodules["deps/openssl/openssl"].fetchRecurseSubmodules, "false")
			assertEquals(submodules["deps/openssl/openssl"].shallow, "true")
			assertEquals(submodules["deps/openssl/openssl"].update, "checkout")
		end)

		it("should normalize iine endings to avoid crossplatform issues", function()
			local fileContentsWithCRLF = fileContents:gsub("\n", "\r\n")
			assertEquals(git.modules(fileContents), git.modules(fileContentsWithCRLF))
		end)
	end)
end)
