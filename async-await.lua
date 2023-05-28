local function ASYNC(task)
	local taskID = task[1]
	local taskFn = task[2]
	print("Scheduling task " .. taskID)
	taskFn()
end

local function asyncTask()
	print("Starting task")
	C_Timer.After(1000, function()
		print("Task completed")
	end)
end

ASYNC {"asyncTask", asyncTask}
