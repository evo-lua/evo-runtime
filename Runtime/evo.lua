local evo = {}

function evo.run()
	evo.loadNonstandardExtensions()

	print("Hello from evo.lua!")

	local scriptFile = arg[0]
	dofile(scriptFile)
end

function evo.loadNonstandardExtensions()
	require("debugx")
	require("stringx")
end

return evo
