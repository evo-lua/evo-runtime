local transform = require("transform")

local function testAllTransforms()
	for name, transformation in pairs(transform) do
		if type(transformation) == "function" and transform.colorCodes[name] then
			local text = "Transformation applied to this text: " .. name
			io.write(string.format("transform.%-25s ~>   ", name))
			print(transformation(text))
		end
	end
end

testAllTransforms()
