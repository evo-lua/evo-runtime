-- Coroutine scheduler
local Scheduler = {
    tasks = {}
}

function Scheduler:run(func, ...)
    local co = coroutine.create(func)
    table.insert(self.tasks, co)
    coroutine.resume(co, ...)
end

function Scheduler:after(time, func)
    local timerId
    timerId = C_Timer.NewTicker(time, function()
        timerId:Cancel()
        func()
    end)
end

function Scheduler:wait(time)
    local co = coroutine.running()
    self:after(time, function()
        assert(coroutine.status(co) == "suspended")
        coroutine.resume(co)
    end)
    coroutine.yield()
end

-- async tasks
local function firstAsyncTask()
    print("Starting task 1")
    Scheduler:wait(1000)
    print("Task 1 completed")
end

local function secondAsyncTask()
    print("Starting task 2")
    Scheduler:wait(1000)
    print("Task 2 completed")
end

local function thirdAsyncTask()
    print("Starting task 3")
    Scheduler:wait(1000)
    print("Task 3 completed")
end

-- scheduling tasks
print("Scheduling task 1")
Scheduler:run(function()
    firstAsyncTask()
    secondAsyncTask()
    thirdAsyncTask()
end)
