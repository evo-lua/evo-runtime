-- TODO move to gpu library

local ffi = require("ffi")
local glfw = require("glfw")
local validation = require("validation")
local webgpu = require("webgpu")

local gpu = {}

function gpu.createInstance()
	local instanceDescriptor = ffi.new("WGPUInstanceDescriptor")
	local instance = webgpu.bindings.wgpu_create_instance(instanceDescriptor)
	if not instance then
		error("Could not initialize WebGPU", 0)
	end

	return {
		handle = instance,
		descriptor = instanceDescriptor,
	}
end

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

function gpu.requestAdapter(gpuInstance, glfwWindowHandle)
	validation.validateTable(gpuInstance, "gpuInstance")
	validation.validateStruct(gpuInstance.handle, "gpuInstance.handle")
	validation.validateStruct(gpuInstance.descriptor, "gpuInstance.descriptor")
	validation.validateStruct(glfwWindowHandle, "glfwWindowHandle")

	local surface = glfw.bindings.glfw_get_wgpu_surface(gpuInstance.handle, glfwWindowHandle)

	local adapterOptions = ffi.new("WGPURequestAdapterOptions")
	adapterOptions.compatibleSurface = surface

	local requestedAdapter = Adapter()
	local function onAdapterRequested(status, adapter, message, userdata)
		assert(status == ffi.C.WGPURequestAdapterStatus_Success, "Failed to request WebGPU adapter")
		requestedAdapter.handle = adapter
	end
	webgpu.bindings.wgpu_instance_request_adapter(gpuInstance.handle, adapterOptions, onAdapterRequested, nil)

	-- This call is blocking (in the wgpu-native implementation), but that might change in the future...
	assert(requestedAdapter.handle, "onAdapterRequested did not trigger, but it should have")

	return requestedAdapter
end

local isWindows = (ffi.os == "Windows")
if not isWindows then
	local transform = require("transform")
	print(transform.yellow("Skipping GPU triangle test (currently only works on Windows runners)"))
	return
end

local clearColor = { red = 0.0, green = 0.5, blue = 1.0, alpha = 1.0 }

-- // Each vertex has 8 values representing position and color: X Y Z W R G B A
-- const vertices = new Float32Array([
--   0.0,  0.6, 0, 1, 1, 0, 0, 1,
--  -0.5, -0.6, 0, 1, 0, 1, 0, 1,
--   0.5, -0.6, 0, 1, 0, 0, 1, 1
-- ]);

-- // Vertex and fragment shaders

-- const shaders = `
-- struct VertexOut {
--   @builtin(position) position : vec4f,
--   @location(0) color : vec4f
-- }

-- @vertex
-- fn vertex_main(@location(0) position: vec4f,
--                @location(1) color: vec4f) -> VertexOut
-- {
--   var output : VertexOut;
--   output.position = position;
--   output.color = color;
--   return output;
-- }

-- @fragment
-- fn fragment_main(fragData: VertexOut) -> @location(0) vec4f
-- {
--   return fragData.color;
-- }
-- `;

-- // Main function

-- local gpu = require("gpu")

local function init()
	-- 0. Create window and WebGPU context (this isn't needed in JS, but here we can create multiple contexts and windows)
	if not glfw.bindings.glfw_init() then
		error("Could not initialize GLFW")
	end

	local GLFW_CLIENT_API = glfw.bindings.glfw_find_constant("GLFW_CLIENT_API")
	local GLFW_NO_API = glfw.bindings.glfw_find_constant("GLFW_NO_API")
	glfw.bindings.glfw_window_hint(GLFW_CLIENT_API, GLFW_NO_API)
	local window = glfw.bindings.glfw_create_window(640, 480, "WebGPU Triangle Rendering Test", nil, nil)
	local instance = gpu.createInstance()

	--   1: request adapter and device
	local adapter = gpu.requestAdapter(instance, window)
	if not adapter then
		error("Couldn't request WebGPU adapter.")
	end

	local device = adapter:RequestLogicalDevice()

	--   // 2: Create a shader module from the shaders template literal
	--   local shaderModule = device.createShaderModule({
	--     code: shaders
	--   });

	--   // 3: Get reference to the canvas to render on
	--   const canvas = document.querySelector('#gpuCanvas');
	--   const context = canvas.getContext('webgpu');

	--   context.configure({
	--     device: device,
	--     format: navigator.gpu.getPreferredCanvasFormat(),
	--     alphaMode: 'premultiplied'
	--   });

	--   // 4: Create vertex buffer to contain vertex data
	--   const vertexBuffer = device.createBuffer({
	--     size: vertices.byteLength, // make it big enough to store vertices in
	--     usage: GPUBufferUsage.VERTEX | GPUBufferUsage.COPY_DST,
	--   });

	--   // Copy the vertex data over to the GPUBuffer using the writeBuffer() utility function
	--   device.queue.writeBuffer(vertexBuffer, 0, vertices, 0, vertices.length);

	--   // 5: Create a GPUVertexBufferLayout and GPURenderPipelineDescriptor to provide a definition of our render pipline
	--   const vertexBuffers = [{
	--     attributes: [{
	--       shaderLocation: 0, // position
	--       offset: 0,
	--       format: 'float32x4'
	--     }, {
	--       shaderLocation: 1, // color
	--       offset: 16,
	--       format: 'float32x4'
	--     }],
	--     arrayStride: 32,
	--     stepMode: 'vertex'
	--   }];

	--   const pipelineDescriptor = {
	--     vertex: {
	--       module: shaderModule,
	--       entryPoint: 'vertex_main',
	--       buffers: vertexBuffers
	--     },
	--     fragment: {
	--       module: shaderModule,
	--       entryPoint: 'fragment_main',
	--       targets: [{
	--         format: navigator.gpu.getPreferredCanvasFormat()
	--       }]
	--     },
	--     primitive: {
	--       topology: 'triangle-list'
	--     },
	--     layout: 'auto'
	--   };

	--   // 6: Create the actual render pipeline

	--   const renderPipeline = device.createRenderPipeline(pipelineDescriptor);

	--   // 7: Create GPUCommandEncoder to issue commands to the GPU
	--   // Note: render pass descriptor, command encoder, etc. are destroyed after use, fresh one needed for each frame.
	--   const commandEncoder = device.createCommandEncoder();

	--   // 8: Create GPURenderPassDescriptor to tell WebGPU which texture to draw into, then initiate render pass

	--   const renderPassDescriptor = {
	--     colorAttachments: [{
	--       clearValue: clearColor,
	--       loadOp: 'clear',
	--       storeOp: 'store',
	--       view: context.getCurrentTexture().createView()
	--     }]
	--   };

	--   const passEncoder = commandEncoder.beginRenderPass(renderPassDescriptor);

	--   // 9: Draw the triangle

	--   passEncoder.setPipeline(renderPipeline);
	--   passEncoder.setVertexBuffer(0, vertexBuffer);
	--   passEncoder.draw(3);

	--   // End the render pass
	--   passEncoder.end();

	--   // 10: End frame by passing array of command buffers to command queue for execution
	--   device.queue.submit([commandEncoder.finish()]);
end

init()
