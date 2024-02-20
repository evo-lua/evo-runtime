local format = string.format
local pairs = pairs

function package.open(pkg)
	for key, value in pairs(pkg) do
		if _G[key] ~= nil then
			error(format("Cannot open package: Global %s is already defined", key), 0)
		end
		_G[key] = value
	end
end
