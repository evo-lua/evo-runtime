local Promise = {}
Promise.__index = Promise

function Promise.new(action)
	local self = setmetatable({}, Promise)
	self.status = 'pending'
	self.then_ = function() end
	action(function()
		self.status = 'resolved'
		self:then_()
	end)
	return self
end

function Promise:then_(func)
	if self.status == 'resolved' then
		func()
	else
		self.then_ = func
	end
end

-- Example usage:

local function asyncTask(name, delay)
	return Promise.new(function(resolve)
		print("Starting task " .. name)
		C_Timer.After(delay, function()
			print("Task " .. name .. " completed")
			resolve()
		end)
	end)
end

print("Scheduling task 1")
asyncTask("1", 1000):then_(function()
	asyncTask("2", 1000):then_(function()
		asyncTask("3", 1000)
	end)
end)
