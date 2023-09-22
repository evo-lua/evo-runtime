local uv = require('uv')

local RED = "\27[31m"
local GREEN = "\27[32m"
local RESET = "\27[0m"
local tty = uv.new_tty(1, false) -- stdout

local startTime = uv.hrtime()
local lastProgress = 0

function display_progress_bar(progress, total, options, callbacks)
	local percentage = progress / total
    -- Check for near completion
    if percentage > 0.99 then -- Avoid rounding errors (missing completion)
        percentage = 1
        progress = total
    end

    local width = tty:get_winsize()
    local barLength = width - 50  -- this is arbitrary, adjust based on other info to display
	local blocks = math.floor(barLength * percentage)
    -- Ensure completion when progress reaches or surpasses total
    -- if progress >= total then
    --     blocks = barLength
    -- end
    local color = (percentage < 0.5) and RED or GREEN

    -- ETA Calculation
    local elapsedTime = (uv.hrtime() - startTime) / 1e9  -- convert to seconds
    local speed = progress / elapsedTime
    local remainingTime = (total - progress) / speed
    local etaDisplay = options.showETA and string.format(" ETA: %.2fs", remainingTime) or ""

    -- Speed/Rate Display
    local speedDisplay = options.showRate and string.format(" Speed: %.2f/s", speed) or ""

    -- Progress Bar Construction
    local progressBar = "\r" .. color
    for i = 1, barLength do
        if i <= blocks then
            progressBar = progressBar .. "━"
        else
            progressBar = progressBar .. " "
        end
    end

    progressBar = progressBar .. RESET
               .. string.format(" %.2f%%", percentage * 100)
               .. speedDisplay
               .. etaDisplay

    tty:write(progressBar)

    -- Handle Callbacks
    if callbacks and type(callbacks) == "table" then
        for event, callback in pairs(callbacks) do
            if event == "onComplete" and percentage == 1 then
                callback()
            end
        end
    end
end

-- Test it
local progress = 0
local total = 555 -- TODO breaks if total is 100
local timer = uv.new_timer()

local function update_progress_bar()
    display_progress_bar(progress, total, { showETA = true, showRate = true }, {
        onComplete = function() print("\nDownload Complete!") end
    })
    progress = progress + 10

    if progress > total then
        timer:close()
        tty:close()
    end
end

timer:start(20, 20, update_progress_bar)

uv.run()
