local stack = _G.CALLSTACK -- Let's just pretend you didn't see this

function stack:push(item)
	table.insert(stack, item)
	print(format("PUSH\t%d\t%s", #stack, item))
end

stack:push("start main chunk")

-- Silently ignored (hooks are stashed when describe runs)
before(function()
	error("Setup in main scope should never run")
end)

-- Silently ignored (hooks are stashed when describe runs)
after(function()
	error("Teardown in main scope should never run")
end)

stack:push("continue main chunk")

describe("section 1", function()
	stack:push("start section 1")

	before(function()
		stack:push("setup subsection (section 1)")
	end)

	after(function()
		stack:push("teardown subsection (section 1)")
	end)

	it("subsection 1.1", function()
		stack:push("start subsection 1.1 (section 1)")
	end)

	it("subsection 1.2", function()
		stack:push("start subsection 1.2 (section 1)")
	end)

	stack:push("continue section 1")

	describe("section 2", function()
		stack:push("start section 2 (section 1)")

		before(function()
			stack:push("setup subsection (section 2)")
		end)

		after(function()
			stack:push("teardown subsection (section 2)")
		end)

		stack:push("continue section 2 (section 1)")

		it("subsection 2.1", function()
			stack:push("start subsection 2.1 (section 2)")
		end)

		it("subsection 2.2", function()
			stack:push("start subsection 2.1 (section 2)")
		end)

		stack:push("end of section 2 reached (section 1)")
	end)

	stack:push("continue section 1")

	describe("section 3", function()
		stack:push("start section 3 (section 1)")

		describe("section 4", function()
			stack:push("start section 4")

			-- There's no more subsections to run in here (as there aren't any it blocks)
			before(function()
				error("Setup in empty section should never run")
			end)

			after(function()
				error("Teardown in empty section should never run")
			end)
		end)

		it("subsection 3.1", function()
			stack:push("start subsection 3.1 (section 3)")
		end)

		it("subsection 3.2", function()
			stack:push("start subsection 3.2 (section 3)")
		end)

		stack:push("end of section 3 reached (section 1)")
	end)

	stack:push("end of section 1 reached")
end)

stack:push("continue with main chunk")

describe("section 5", function()
	stack:push("start section 5")

	it("subsection 5.1", function()
		stack:push("start subsection 5.1 (section 5)")
	end)
end)

stack:push("EOF reached in main chunk")
