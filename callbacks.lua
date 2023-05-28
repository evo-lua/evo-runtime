local function firstAsyncTask()
	print("Starting task 1")
	C_Timer.After(1000, function()
		print("Task 1 completed")
	end)
end

local function secondAsyncTask()
	print("Starting task 2")
	C_Timer.After(1000, function()
		print("Task 2 completed")
	end)
end

local function thirdAsyncTask()
	print("Starting task 3")
	C_Timer.After(1000, function()
		print("Task 3 completed")
	end)
end

print("Scheduling task 1")
firstAsyncTask()

print("Scheduling task 2")
secondAsyncTask()

print("Scheduling task 3")
thirdAsyncTask()
