local bit = require("bit")
local console = require("console")

local SAMPLE_SIZE = 100000000

local function bitceil_lua(n)
	if n <= 0 then
		return 1
	end

	if bit.band(n, (n - 1)) == 0 then
		return n
	end

	local power = 1
	while power < n do
		power = power * 2
	end

	return power
end

math.randomseed(os.clock())
local availableBenchmarks = {
	function()
		local label = "[Lua] Compute bit.ceil (naive approach)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			bitceil_lua(i)
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[FFI] Compute bit.ceil (using std::bit_ceil)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			bit.ceil(i)
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[FFI] Compute bit.floor (using std::bit_floor)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			bit.floor(i)
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[FFI] Compute bit.width (using std::bit_width)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			bit.width(i)
		end
		console.stopTimer(label)
	end,
	function()
		local label = "[FFI] Compute bit.ispow2 (using std::has_single_bit)"
		console.startTimer(label)
		for i = 1, SAMPLE_SIZE, 1 do
			bit.ispow2(i)
		end
		console.stopTimer(label)
	end,
}

local function shuffle(tbl)
	for i = #tbl, 2, -1 do
		local j = math.random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
end

shuffle(availableBenchmarks)

for _, benchmark in ipairs(availableBenchmarks) do
	benchmark()
end
