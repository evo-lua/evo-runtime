local lpeg = require("lpeg")
local re = require("re")

describe("lpeg", function()
	local exportedFunctions = {
		"B",
		"C",
		"Carg",
		"Cb",
		"Cc",
		"Cf",
		"Cg",
		"Cmt",
		"Cp",
		"Cs",
		"Ct",
		"P",
		"R",
		"S",
		"V",
		"locale",
		"match",
		"pcode",
		"ptree",
		"setmaxstack",
		"type",
		"utfR",
	}

	it("should export all LPEG functions", function()
		for _, functionName in ipairs(exportedFunctions) do
			local exportedFunction = lpeg[functionName]
			assertEquals(type(exportedFunction), "function", "Should export function " .. functionName)
		end
	end)

	-- Example taken from https://www.inf.puc-rio.br/~roberto/lpeg/ (not a real test, but better than nothing)
	it("should allow parsing arithmetic expressions", function()
		-- Lexical Elements
		local Space = lpeg.S(" \n\t") ^ 0
		local Number = lpeg.C(lpeg.P("-") ^ -1 * lpeg.R("09") ^ 1) * Space
		local TermOp = lpeg.C(lpeg.S("+-")) * Space
		local FactorOp = lpeg.C(lpeg.S("*/")) * Space
		local Open = "(" * Space
		local Close = ")" * Space

		-- Grammar
		local Exp, Term, Factor = lpeg.V("Exp"), lpeg.V("Term"), lpeg.V("Factor")
		local G = lpeg.P({
			Exp,
			Exp = lpeg.Ct(Term * (TermOp * Term) ^ 0),
			Term = lpeg.Ct(Factor * (FactorOp * Factor) ^ 0),
			Factor = Number + Open * Exp * Close,
		})

		G = Space * G * -1

		-- Evaluator
		local function eval(x)
			if type(x) == "string" then
				return tonumber(x)
			else
				local op1 = eval(x[1])
				for i = 2, #x, 2 do
					local op = x[i]
					local op2 = eval(x[i + 1])
					if op == "+" then
						op1 = op1 + op2
					elseif op == "-" then
						op1 = op1 - op2
					elseif op == "*" then
						op1 = op1 * op2
					elseif op == "/" then
						op1 = op1 / op2
					end
				end
				return op1
			end
		end

		-- Parser/Evaluator
		local function evalExp(s)
			local t = lpeg.match(G, s)
			if not t then
				error("syntax error", 2)
			end
			return eval(t)
		end

		local result = evalExp("3 + 5*9 / (1+1) - 12")
		assertEquals(result, 13.5)
	end)

	describe("version", function()
		it("should contain the embedded LPEG version in semver format", function()
			-- A match here indicates the prefix is no longer present
			local firstMatchedCharacterIndex, lastMatchedCharacterIndex =
				string.find(lpeg.version, "LPeg%s(%d+.%d+.%d+)")
			assertEquals(firstMatchedCharacterIndex, 1)
			assertEquals(lastMatchedCharacterIndex, string.len(lpeg.version))
			assertEquals(type(string.match(lpeg.version, "%d+.%d+.%d+")), "string")
		end)
	end)
end)

describe("re", function()
	local exportedFunctions = {
		"compile",
		"find",
		"gsub",
		"match",
		"updatelocale",
	}

	it("should export all LPEG-RE functions", function()
		for _, functionName in ipairs(exportedFunctions) do
			local exportedFunction = re[functionName]
			assertEquals(type(exportedFunction), "function", "Should export function " .. functionName)
		end
	end)
end)
