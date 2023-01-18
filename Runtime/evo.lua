local evo = {}

function evo.run()
	evo.setupGlobalEnvironment()
	evo.loadNonstandardExtensions()

	print("Hello from evo.lua!")

	local scriptFile = arg[0]
	dofile(scriptFile)
end

function evo.setupGlobalEnvironment()
	-- Lua 5.2 compatibility (required for the diff-match-patch library)
	_G.bit32 = require("bit")
end

function evo.loadNonstandardExtensions()
	require("debugx")
end

return evo
