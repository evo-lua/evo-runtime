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

local total = 100
for i = 0, total do
    os.execute("sleep 0.02") -- Sleep for 20 milliseconds
    display_progress_bar(i / total)
end
print() -- Print newline after loop completes
