local ffi = require("ffi")
local glfw = require("glfw")
local validation = require("validation")
local webgpu = require("webgpu")

local gpu = {}

local Device = {}

function Device:Construct()
	local instance = {}
	setmetatable(instance, { __index = Device })
	return instance
end

setmetatable(Device, { __call = Device.Construct })

local Adapter = {}

function Adapter:Construct()
	local instance = {}
	setmetatable(instance, { __index = Adapter })
	return instance
end

function Adapter:RequestLogicalDevice()
	return Device()
end

setmetatable(Adapter, { __call = Adapter.Construct })

function gpu.requestAdapter(glfwWindowHandle)
	validation.validateStruct(glfwWindowHandle, "glfwWindowHandle")
	local surface = glfw.bindings.glfw_get_wgpu_surface(gpu.instance, glfwWindowHandle)

	local adapterOptions = ffi.new("WGPURequestAdapterOptions")
	adapterOptions.compatibleSurface = surface

	local requestedAdapter = Adapter()
	local function onAdapterRequested(status, adapter, message, userdata)
		assert(status == ffi.C.WGPURequestAdapterStatus_Success, "Failed to request WebGPU adapter")
		requestedAdapter.handle = adapter
	end
	webgpu.bindings.wgpu_instance_request_adapter(gpu.instance, adapterOptions, onAdapterRequested, nil)

	-- This call is blocking (in the wgpu-native implementation), but that might change in the future...
	assert(requestedAdapter.handle, "onAdapterRequested did not trigger, but it should have")

	return requestedAdapter
end

-- Since most apps will only ever need a single instance, automatically create one on load
local globalInstanceDescriptor = ffi.new("WGPUInstanceDescriptor")
local globalContext = webgpu.bindings.wgpu_create_instance(globalInstanceDescriptor)

if not globalContext then
	error("Failed to initialize global WebGPU context (could not connect to the GPU)", 0)
end

gpu.instance = globalContext

return gpu
