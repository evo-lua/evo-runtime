local validation = require("validation")

local gpu = {}

function gpu.createInstance(gltfWindowHandle)
	validation.validateStruct(gltfWindowHandle, "gltfWindowHandle")
end

return gpu
