local ffi = require("ffi")
local glfw = require("glfw")
local wgpu = require("wgpu")

local isMacOS = (ffi.os == "OSX")
if isMacOS then
	-- CI runner gets stuck after the window closes. See https://github.com/glfw/glfw/issues/1766
	return
end

local instanceDescriptor = ffi.new("WGPUInstanceDescriptor")
local instance = wgpu.bindings.wgpu_create_instance(instanceDescriptor)
if not instance then
	error("Could not initialize WebGPU!")
end

if not glfw.bindings.glfw_init() then
	error("Could not initialize GLFW")
end

local GLFW_CLIENT_API = glfw.bindings.glfw_find_constant("GLFW_CLIENT_API")
local GLFW_NO_API = glfw.bindings.glfw_find_constant("GLFW_NO_API")
glfw.bindings.glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)

local window = glfw.bindings.glfw_create_window(640, 480, "WebGPU Surface Test", nil, nil)
assert(window, "Failed to create window")

print("Requesting adapter...")
local surface = glfw.bindings.glfw_get_wgpu_surface(instance, window)
assert(surface, "Failed to create WebGPU surface")

local adapterOpts = ffi.new("WGPURequestAdapterOptions")
adapterOpts.compatibleSurface = surface

local requestedAdapter
local function onAdapterRequested(status, adapter, message, pUserData)
	print("onAdapterRequested", status, adapter, message, pUserData)
	assert(status == ffi.C.WGPURequestAdapterStatus_Success, "Failed to request adapter")
	requestedAdapter = adapter
end
wgpu.bindings.wgpu_instance_request_adapter(instance, adapterOpts, onAdapterRequested, nil)
print("Got adapter: ", requestedAdapter)

local function inspectAdapter(adapter)
	local featureCount = wgpu.bindings.wgpu_adapter_enumerate_features(adapter, nil)
	local features = ffi.new("WGPUFeatureName[?]", featureCount)
	wgpu.bindings.wgpu_adapter_enumerate_features(adapter, features)

	print("Adapter features:")
	for index = 0, tonumber(featureCount) - 1 do
		local feature = features[index]
		print(index + 1, feature)
	end

	local limits = ffi.new("WGPUSupportedLimits")
	local success = wgpu.bindings.wgpu_adapter_get_limits(adapter, limits)
	assert(success, "Failed to get adapter limits")

	print("Adapter limits:")
	print("\tmaxTextureDimension1D: ", limits.limits.maxTextureDimension1D)
	print("\tmaxTextureDimension2D: ", limits.limits.maxTextureDimension2D)
	print("\tmaxTextureDimension3D: ", limits.limits.maxTextureDimension3D)
	print("\tmaxTextureArrayLayers: ", limits.limits.maxTextureArrayLayers)
	print("\tmaxBindGroups: ", limits.limits.maxBindGroups)
	print("\tmaxDynamicUniformBuffersPerPipelineLayout: ", limits.limits.maxDynamicUniformBuffersPerPipelineLayout)
	print("\tmaxDynamicStorageBuffersPerPipelineLayout: ", limits.limits.maxDynamicStorageBuffersPerPipelineLayout)
	print("\tmaxSampledTexturesPerShaderStage: ", limits.limits.maxSampledTexturesPerShaderStage)
	print("\tmaxSamplersPerShaderStage: ", limits.limits.maxSamplersPerShaderStage)
	print("\tmaxStorageBuffersPerShaderStage: ", limits.limits.maxStorageBuffersPerShaderStage)
	print("\tmaxStorageTexturesPerShaderStage: ", limits.limits.maxStorageTexturesPerShaderStage)
	print("\tmaxUniformBuffersPerShaderStage: ", limits.limits.maxUniformBuffersPerShaderStage)
	print("\tmaxUniformBufferBindingSize: ", limits.limits.maxUniformBufferBindingSize)
	print("\tmaxStorageBufferBindingSize: ", limits.limits.maxStorageBufferBindingSize)
	print("\tminUniformBufferOffsetAlignment: ", limits.limits.minUniformBufferOffsetAlignment)
	print("\tminStorageBufferOffsetAlignment: ", limits.limits.minStorageBufferOffsetAlignment)
	print("\tmaxVertexBuffers: ", limits.limits.maxVertexBuffers)
	print("\tmaxVertexAttributes: ", limits.limits.maxVertexAttributes)
	print("\tmaxVertexBufferArrayStride: ", limits.limits.maxVertexBufferArrayStride)
	print("\tmaxInterStageShaderComponents: ", limits.limits.maxInterStageShaderComponents)
	print("\tmaxComputeWorkgroupStorageSize: ", limits.limits.maxComputeWorkgroupStorageSize)
	print("\tmaxComputeInvocationsPerWorkgroup: ", limits.limits.maxComputeInvocationsPerWorkgroup)
	print("\tmaxComputeWorkgroupSizeX: ", limits.limits.maxComputeWorkgroupSizeX)
	print("\tmaxComputeWorkgroupSizeY: ", limits.limits.maxComputeWorkgroupSizeY)
	print("\tmaxComputeWorkgroupSizeZ: ", limits.limits.maxComputeWorkgroupSizeZ)
	print("\tmaxComputeWorkgroupsPerDimension: ", limits.limits.maxComputeWorkgroupsPerDimension)

	local properties = ffi.new("WGPUAdapterProperties")
	wgpu.bindings.wgpu_adapter_get_properties(adapter, properties)

	print("Adapter properties:")
	print("\tvendorID: ", properties.vendorID)
	print("\tdeviceID: ", properties.deviceID)
	print("\tname: ", ffi.string(properties.name))
	if properties.driverDescription then
		print("\tdriverDescription: ", ffi.string(properties.driverDescription))
	end
	print("\tadapterType: ", properties.adapterType)
	print("\tbackendType: ", properties.backendType)
end

inspectAdapter(requestedAdapter)
