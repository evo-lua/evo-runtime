local ffi = require("ffi")
local path = require("path")

local assertStrictEqual = assertEquals

local type = type
local pairs = pairs
local ipairs = ipairs
local dofile = dofile

describe("path", function()
	it("should pass all the ported NodeJS tests", function()
		-- Default to the detected OS convention (default assert prevents stack overflow due to runaway deep comparisons)
		if ffi.os == "Windows" then
			assertStrictEqual(path.convention, "Windows", "Should default to Windows path library on Windows systems")
			assert(path == path.win32, "The Path API must be using path.win32 on Windows")
		else
			assertStrictEqual(path.convention, "POSIX", "Should default to POSIX path library on non-Windows systems")
			assert(path == path.posix, "The Path API must be using path.posix on POSIX-compliant platforms")
		end

		-- Type errors: Only strings are valid paths(* excluding optional args)
		local invalidTypeValues = { true, false, 7, nil, {}, 42.0 }

		local function assertFailure(func, ...)
			local result, errorMessage = func(...)
			-- invalid types should return nil and error (Lua style), not errors (JavaScript style)
			assertStrictEqual(result, nil, "Should return nil if invalid parameters are passed")
			assertStrictEqual(
				type(errorMessage),
				"string",
				"Should return an error message if invalid parameters are passed"
			)
			assertStrictEqual(
				errorMessage:find("Usage: "),
				1,
				"Should return an error message of the form 'Usage: ...' when invalid parameters are passed"
			)
		end

		local functionsToTest = {
			"join",
			"resolve",
			"normalize",
			"isAbsolute",
			"relative",
			"dirname",
			"basename",
			"extname",
		}

		for key, value in pairs(invalidTypeValues) do
			for name, namespace in pairs({ win32 = path.win32, posix = path.posix }) do
				for index, func in ipairs(functionsToTest) do
					assertFailure(namespace[func], value)
				end

				-- These don't really fit the pattern, so just add them manually
				assertFailure(namespace.relative, value, "foo")
				assertFailure(namespace.relative, "foo", value)
			end
		end

		-- Path separators and delimiters should be consistent with the respective OS' convention
		assertStrictEqual(path.win32.separator, "\\", "Windows path separator must be BACKSLASH")
		assertStrictEqual(path.posix.separator, "/", "POSIX path separator must be FORWARD_SLASH")
		assertStrictEqual(path.win32.delimiter, ";", "Windows path delimiter must be SEMICOLON")
		assertStrictEqual(path.posix.delimiter, ":", "POSIX path delimiter must be COLON")

		assertStrictEqual(type(path.win32), "table", "The win32 path library must exist")
		assertStrictEqual(type(path.posix), "table", "The posix path library must exist")

		dofile("Tests/BDD/path-library/test-path-dirname.lua")
		dofile("Tests/BDD/path-library/test-path-basename.lua")
		dofile("Tests/BDD/path-library/test-path-isabsolute.lua")
		dofile("Tests/BDD/path-library/test-path-normalize.lua")
		dofile("Tests/BDD/path-library/test-path-extname.lua")
		dofile("Tests/BDD/path-library/test-path-resolve.lua")
		dofile("Tests/BDD/path-library/test-path-join.lua")
		dofile("Tests/BDD/path-library/test-path-relative.lua")
	end)
end)
