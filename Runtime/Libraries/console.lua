local console = {
	buffer = buffer.new(),
	backup = {},
}

function console.capture()
	local hasCapturedBefore = (console.backup.print ~= nil)
	if hasCapturedBefore then
		console.buffer:reset()
		return
	end

	console.backup.print = _G.print
	_G.print = console.print
end

function console.print(...)
	local args = { ... }
	for k, v in ipairs(args) do
		console.buffer:put(v .. "\n")
	end
end

function console.release()
	local hasCapturedBefore = (console.backup.print ~= nil)
	if not hasCapturedBefore then
		return
	end

	_G.print = console.backup.print
	console.backup = {}

	local capturedOutput = tostring(console.buffer)
	console.buffer:reset()
	return capturedOutput
end

return console
