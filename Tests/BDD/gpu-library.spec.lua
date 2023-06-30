local gpu = require("gpu")

describe("gpu", function()
	describe("adapter", function() end)

	describe("device", function() end)

	describe("createInstance", function()
		it("should throw if no window handle was given", function()
			assertThrows(function()
				gpu.createInstance()
			end, "Expected argument gltfWindowHandle to be a cdata value, but received a nil value instead")
		end)
	end)

	describe("requestAdapter", function() end)
end)
