local uv = require('uv')

-- ANSI Escape codes for colors
local RED = "\27[31m"
local GREEN = "\27[32m"
local RESET = "\27[0m"

function display_progress_bar(percentage)
    local bar_length = 50
    local blocks = math.floor(bar_length * percentage)

    -- Determine color based on progress
    local color = (percentage < 0.5) and RED or GREEN

    -- Build the progress bar string
    io.write("\r     " .. color)
    for i = 1, bar_length do
        if i <= blocks then
            io.write("━")
        else
            io.write(" ")
        end
    end
    io.write(RESET .. " " .. percentage * 100 .. "%")
    io.flush()
end

local i = 0
local total = 100

local timer = uv.new_timer()

local function update_progress_bar()
    display_progress_bar(i / total)
    i = i + 1

    if i > total then
        timer:close()
        print()  -- Print newline after loop completes
    end
end

-- Start the timer: The first '20' is the delay before the timer starts, 
-- and the second '20' is the interval at which it fires.
timer:start(20, 20, update_progress_bar)

-- Run the libuv loop
uv.run()
