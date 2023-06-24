-- Based on https://eliemichel.github.io/LearnWebGPU/basic-3d-rendering/hello-triangle.html
local gpu = require("Runtime.API.WebGPU.gpu")

local context = gpu.initialize_webgpu_context()
local window = gpu.create_gltf_window()
local adapter = gpu.request_adapter_for_window_surface(context, window)

local deviceInfo = gpu.request_device_for_adapter(adapter)

local chain = gpu.create_swap_chain_for_window_surface(context, window, deviceInfo.device, adapter)

local pipeline = gpu.create_triangle_render_pipeline(deviceInfo.device, context, window, adapter)

assert(pipeline, "Failed to create triangle rendering pipeline")

-- HACK, passing via globals (yeah, I know)
_G.TRIANGLE_RENDERING_PIPELINE = pipeline

-- Can now run the GLFW UI loop, either manually or with a polling timer (requires libuv)
local success, uv = pcall(require, "uv")
local isAsyncRuntime = success and (type(uv) == "table")
if isAsyncRuntime then
	print("Starting UI loop with a polling timer (non-blocking) ...")
	gpu.run_ui_loop_with_libuv(window, deviceInfo.device, chain)
else
	print("Starting UI loop with GLFW (blocking) ...")
	gpu.run_ui_loop_with_glfw(window, deviceInfo.device, chain)
end
