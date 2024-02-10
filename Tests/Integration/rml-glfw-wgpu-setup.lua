local ffi = require("ffi")
local glfw = require("glfw")
local interop = require("interop")
local rml = require("rml")
local webgpu = require("webgpu")

local isMacOS = (ffi.os == "OSX")
if isMacOS then
	-- CI runner gets stuck after the window closes. See https://github.com/glfw/glfw/issues/1766
	return
end

-- GLFW setup
local function createWindow()
	assert(glfw.init())

	local GLFW_CLIENT_API = glfw.find_constant("GLFW_CLIENT_API")
	local GLFW_NO_API = glfw.find_constant("GLFW_NO_API")
	glfw.window_hint(GLFW_CLIENT_API, GLFW_NO_API)

	local window = glfw.create_window(640, 480, "RML/GLFW/WebGPU Integration Test", nil, nil)
	assert(window, "Failed to create window")

	return window
end

-- WebGPU setup
local function createDevice(window)
	local instanceDescriptor = ffi.new("WGPUInstanceDescriptor")
	local instance = webgpu.bindings.wgpu_create_instance(instanceDescriptor)
	if not instance then
		error("Could not initialize WebGPU!")
	end

	local surface = glfw.get_wgpu_surface(instance, window)
	assert(surface, "Failed to create WebGPU surface")

	local adapterOptions = ffi.new("WGPURequestAdapterOptions")
	adapterOptions.compatibleSurface = surface

	local requestedAdapter
	local function onAdapterRequested(status, adapter, message, pUserData)
		assert(status == ffi.C.WGPURequestAdapterStatus_Success, "Failed to request adapter")
		requestedAdapter = adapter
	end
	webgpu.bindings.wgpu_instance_request_adapter(instance, adapterOptions, onAdapterRequested, nil)

	local requestedDevice
	local function onDeviceRequested(status, device, message, userdata)
		local success = status == ffi.C.WGPURequestDeviceStatus_Success
		if not success then
			error(
				format(
					"Failed to request logical WebGPU device (status: %s)\n%s",
					tonumber(status),
					ffi.string(message)
				)
			)
		end
		requestedDevice = device
	end

	local deviceDescriptor = ffi.new("WGPUDeviceDescriptor")
	webgpu.bindings.wgpu_adapter_request_device(requestedAdapter, deviceDescriptor, onDeviceRequested, nil)
	assert(requestedDevice, "onDeviceRequested did not trigger, but it should have")

	return requestedDevice
end

local glfwWindow = createWindow()
local wgpuDevice = createDevice(glfwWindow)

-- RML UI setup
local renderCommandQueue = interop.bindings.queue_create()
local ROBOTO_FILE_PATH = path.join("Tests", "Fixtures", "RobotoFont", "Roboto-Regular.ttf")
local DOCUMENT_FILE_PATH = path.join("Tests", "Fixtures", "test.rml")

local glfwSystemInterface = rml.bindings.rml_create_glfw_system_interface()
local wgpuRenderInterface = rml.bindings.rml_create_wgpu_render_interface(wgpuDevice, renderCommandQueue)
rml.bindings.rml_set_system_interface(glfwSystemInterface)
rml.bindings.rml_set_render_interface(wgpuRenderInterface)
rml.bindings.rml_initialise()
rml.bindings.rml_load_font_face(ROBOTO_FILE_PATH, true)

local rmlContext = rml.bindings.rml_context_create("default", 640, 480)
assert(rmlContext ~= ffi.NULL, "Failed to create RML library context")

local document = rml.bindings.rml_context_load_document(rmlContext, DOCUMENT_FILE_PATH)
assert(document ~= ffi.NULL, "Failed to load RML document")
rml.bindings.rml_document_show(document)

local ticker = C_Timer.NewTicker(250, function()
	glfw.poll_events()
	-- Full context updates won't work here (too much WebGPU boilerplate required), so this'll have to do for now
	rml.bindings.rml_context_update(nil)
	rml.bindings.rml_context_render(nil)
end)

C_Timer.After(2000, function()
	ticker:stop()
end)

-- Teardown
rml.bindings.rml_context_remove("default")
rml.bindings.rml_shutdown()
rml.bindings.rml_destroy_glfw_system_interface(glfwSystemInterface)
rml.bindings.rml_destroy_wgpu_render_interface(wgpuRenderInterface)

glfw.destroy_window(glfwWindow)
glfw.terminate()
