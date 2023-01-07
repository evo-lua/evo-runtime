local evo = {}

function evo.run()
	print("Hello from evo.lua!")

	local scriptFile = arg[0]
	dofile(scriptFile)
end

return evo
