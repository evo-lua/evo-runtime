#pragma once

#include <webgpu.h>

struct static_webgpu_exports_table {
	const char* (*wgpu_version)();
	WGPUInstance (*wgpu_create_instance)(WGPUInstanceDescriptor const* descriptor);
	WGPUProc (*wgpu_get_proc_address)(WGPUDevice device, char const* procName);
	size_t (*wgpu_adapter_enumerate_features)(WGPUAdapter adapter, WGPUFeatureName* features);
	bool (*wgpu_adapter_get_limits)(WGPUAdapter adapter, WGPUSupportedLimits* limits);
	void (*wgpu_adapter_get_properties)(WGPUAdapter adapter, WGPUAdapterProperties* properties);
	bool (*wgpu_adapter_has_feature)(WGPUAdapter adapter, WGPUFeatureName feature);
	void (*wgpu_adapter_request_device)(WGPUAdapter adapter, WGPUDeviceDescriptor const* descriptor /* nullable */, WGPURequestDeviceCallback callback, void* userdata);
	void (*wgpu_bind_group_set_label)(WGPUBindGroup bindGroup, char const* label);
	void (*wgpu_bind_group_layout_set_label)(WGPUBindGroupLayout bindGroupLayout, char const* label);
	void (*wgpu_buffer_destroy)(WGPUBuffer buffer);
	void const* (*wgpu_buffer_get_const_mapped_range)(WGPUBuffer buffer, size_t offset, size_t size);
	WGPUBufferMapState (*wgpu_buffer_get_map_state)(WGPUBuffer buffer);
	void* (*wgpu_buffer_get_mapped_range)(WGPUBuffer buffer, size_t offset, size_t size);
	uint64_t (*wgpu_buffer_get_size)(WGPUBuffer buffer);
	WGPUBufferUsage (*wgpu_buffer_get_usage)(WGPUBuffer buffer);
	void (*wgpu_buffer_map_async)(WGPUBuffer buffer, WGPUMapModeFlags mode, size_t offset, size_t size, WGPUBufferMapCallback callback, void* userdata);
	void (*wgpu_buffer_set_label)(WGPUBuffer buffer, char const* label);
	void (*wgpu_buffer_unmap)(WGPUBuffer buffer);
	void (*wgpu_command_buffer_set_label)(WGPUCommandBuffer commandBuffer, char const* label);
	WGPUComputePassEncoder (*wgpu_command_encoder_begin_compute_pass)(WGPUCommandEncoder commandEncoder, WGPUComputePassDescriptor const* descriptor /* nullable */);
	WGPURenderPassEncoder (*wgpu_command_encoder_begin_render_pass)(WGPUCommandEncoder commandEncoder, WGPURenderPassDescriptor const* descriptor);
	void (*wgpu_command_encoder_clear_buffer)(WGPUCommandEncoder commandEncoder, WGPUBuffer buffer, uint64_t offset, uint64_t size);
	void (*wgpu_command_encoder_copy_buffer_to_buffer)(WGPUCommandEncoder commandEncoder, WGPUBuffer source, uint64_t sourceOffset, WGPUBuffer destination, uint64_t destinationOffset, uint64_t size);
	void (*wgpu_command_encoder_copy_buffer_to_texture)(WGPUCommandEncoder commandEncoder, WGPUImageCopyBuffer const* source, WGPUImageCopyTexture const* destination, WGPUExtent3D const* copySize);
	void (*wgpu_command_encoder_copy_texture_to_buffer)(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const* source, WGPUImageCopyBuffer const* destination, WGPUExtent3D const* copySize);
	void (*wgpu_command_encoder_copy_texture_to_texture)(WGPUCommandEncoder commandEncoder, WGPUImageCopyTexture const* source, WGPUImageCopyTexture const* destination, WGPUExtent3D const* copySize);
	WGPUCommandBuffer (*wgpu_command_encoder_finish)(WGPUCommandEncoder commandEncoder, WGPUCommandBufferDescriptor const* descriptor /* nullable */);
	void (*wgpu_command_encoder_insert_debug_marker)(WGPUCommandEncoder commandEncoder, char const* markerLabel);
	void (*wgpu_command_encoder_pop_debug_group)(WGPUCommandEncoder commandEncoder);
	void (*wgpu_command_encoder_push_debug_group)(WGPUCommandEncoder commandEncoder, char const* groupLabel);
	void (*wgpu_command_encoder_resolve_query_set)(WGPUCommandEncoder commandEncoder, WGPUQuerySet querySet, uint32_t firstQuery, uint32_t queryCount, WGPUBuffer destination, uint64_t destinationOffset);
	void (*wgpu_command_encoder_set_label)(WGPUCommandEncoder commandEncoder, char const* label);
	void (*wgpu_command_encoder_write_timestamp)(WGPUCommandEncoder commandEncoder, WGPUQuerySet querySet, uint32_t queryIndex);
	void (*wgpu_compute_pass_encoder_begin_pipeline_statistics_query)(WGPUComputePassEncoder computePassEncoder, WGPUQuerySet querySet, uint32_t queryIndex);
	void (*wgpu_compute_pass_encoder_dispatch_workgroups)(WGPUComputePassEncoder computePassEncoder, uint32_t workgroupCountX, uint32_t workgroupCountY, uint32_t workgroupCountZ);
	void (*wgpu_compute_pass_encoder_dispatch_workgroups_indirect)(WGPUComputePassEncoder computePassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
	void (*wgpu_compute_pass_encoder_end)(WGPUComputePassEncoder computePassEncoder);
	void (*wgpu_compute_pass_encoder_end_pipeline_statistics_query)(WGPUComputePassEncoder computePassEncoder);
	void (*wgpu_compute_pass_encoder_insert_debug_marker)(WGPUComputePassEncoder computePassEncoder, char const* markerLabel);
	void (*wgpu_compute_pass_encoder_pop_debug_group)(WGPUComputePassEncoder computePassEncoder);
	void (*wgpu_compute_pass_encoder_push_debug_group)(WGPUComputePassEncoder computePassEncoder, char const* groupLabel);
	void (*wgpu_compute_pass_encoder_set_bind_group)(WGPUComputePassEncoder computePassEncoder, uint32_t groupIndex, WGPUBindGroup group, uint32_t dynamicOffsetCount, uint32_t const* dynamicOffsets);
	void (*wgpu_compute_pass_encoder_set_label)(WGPUComputePassEncoder computePassEncoder, char const* label);
	void (*wgpu_compute_pass_encoder_set_pipeline)(WGPUComputePassEncoder computePassEncoder, WGPUComputePipeline pipeline);
	WGPUBindGroupLayout (*wgpu_compute_pipeline_get_bind_group_layout)(WGPUComputePipeline computePipeline, uint32_t groupIndex);
	void (*wgpu_compute_pipeline_set_label)(WGPUComputePipeline computePipeline, char const* label);
	WGPUBindGroup (*wgpu_device_create_bind_group)(WGPUDevice device, WGPUBindGroupDescriptor const* descriptor);
	WGPUBindGroupLayout (*wgpu_device_create_bind_group_layout)(WGPUDevice device, WGPUBindGroupLayoutDescriptor const* descriptor);
	WGPUBuffer (*wgpu_device_create_buffer)(WGPUDevice device, WGPUBufferDescriptor const* descriptor);
	WGPUCommandEncoder (*wgpu_device_create_command_encoder)(WGPUDevice device, WGPUCommandEncoderDescriptor const* descriptor /* nullable */);
	WGPUComputePipeline (*wgpu_device_create_compute_pipeline)(WGPUDevice device, WGPUComputePipelineDescriptor const* descriptor);
	void (*wgpu_device_create_compute_pipeline_async)(WGPUDevice device, WGPUComputePipelineDescriptor const* descriptor, WGPUCreateComputePipelineAsyncCallback callback, void* userdata);
	WGPUPipelineLayout (*wgpu_device_create_pipeline_layout)(WGPUDevice device, WGPUPipelineLayoutDescriptor const* descriptor);
	WGPUQuerySet (*wgpu_device_create_query_set)(WGPUDevice device, WGPUQuerySetDescriptor const* descriptor);
	WGPURenderBundleEncoder (*wgpu_device_create_render_bundle_encoder)(WGPUDevice device, WGPURenderBundleEncoderDescriptor const* descriptor);
	WGPURenderPipeline (*wgpu_device_create_render_pipeline)(WGPUDevice device, WGPURenderPipelineDescriptor const* descriptor);
	void (*wgpu_device_create_render_pipeline_async)(WGPUDevice device, WGPURenderPipelineDescriptor const* descriptor, WGPUCreateRenderPipelineAsyncCallback callback, void* userdata);
	WGPUSampler (*wgpu_device_create_sampler)(WGPUDevice device, WGPUSamplerDescriptor const* descriptor /* nullable */);
	WGPUShaderModule (*wgpu_device_create_shader_module)(WGPUDevice device, WGPUShaderModuleDescriptor const* descriptor);
	WGPUSwapChain (*wgpu_device_create_swapchain)(WGPUDevice device, WGPUSurface surface, WGPUSwapChainDescriptor const* descriptor);
	WGPUTexture (*wgpu_device_create_texture)(WGPUDevice device, WGPUTextureDescriptor const* descriptor);
	void (*wgpu_device_destroy)(WGPUDevice device);
	size_t (*wgpu_device_enumerate_features)(WGPUDevice device, WGPUFeatureName* features);
	bool (*wgpu_device_get_limits)(WGPUDevice device, WGPUSupportedLimits* limits);
	WGPUQueue (*wgpu_device_get_queue)(WGPUDevice device);
	bool (*wgpu_device_has_feature)(WGPUDevice device, WGPUFeatureName feature);
	bool (*wgpu_device_pop_error_scope)(WGPUDevice device, WGPUErrorCallback callback, void* userdata);
	void (*wgpu_device_push_error_scope)(WGPUDevice device, WGPUErrorFilter filter);
	void (*wgpu_device_set_device_lost_callback)(WGPUDevice device, WGPUDeviceLostCallback callback, void* userdata);
	void (*wgpu_device_set_label)(WGPUDevice device, char const* label);
	void (*wgpu_device_set_uncaptured_error_callback)(WGPUDevice device, WGPUErrorCallback callback, void* userdata);
	WGPUSurface (*wgpu_instance_create_surface)(WGPUInstance instance, WGPUSurfaceDescriptor const* descriptor);
	void (*wgpu_instance_process_events)(WGPUInstance instance);
	void (*wgpu_instance_request_adapter)(WGPUInstance instance, WGPURequestAdapterOptions const* options /* nullable */, WGPURequestAdapterCallback callback, void* userdata);
	void (*wgpu_pipeline_layout_set_label)(WGPUPipelineLayout pipelineLayout, char const* label);
	void (*wgpu_query_set_destroy)(WGPUQuerySet querySet);
	uint32_t (*wgpu_query_set_get_count)(WGPUQuerySet querySet);
	WGPUQueryType (*wgpu_query_set_get_type)(WGPUQuerySet querySet);
	void (*wgpu_query_set_set_label)(WGPUQuerySet querySet, char const* label);
	void (*wgpu_queue_on_submitted_work_done)(WGPUQueue queue, WGPUQueueWorkDoneCallback callback, void* userdata);
	void (*wgpu_queue_set_label)(WGPUQueue queue, char const* label);
	void (*wgpu_queue_submit)(WGPUQueue queue, uint32_t commandCount, WGPUCommandBuffer const* commands);
	void (*wgpu_queue_write_buffer)(WGPUQueue queue, WGPUBuffer buffer, uint64_t bufferOffset, void const* data, size_t size);
	void (*wgpu_queue_write_texture)(WGPUQueue queue, WGPUImageCopyTexture const* destination, void const* data, size_t dataSize, WGPUTextureDataLayout const* dataLayout, WGPUExtent3D const* writeSize);
	void (*wgpu_render_bundle_encoder_draw)(WGPURenderBundleEncoder renderBundleEncoder, uint32_t vertexCount, uint32_t instanceCount, uint32_t firstVertex, uint32_t firstInstance);
	void (*wgpu_render_bundle_encoder_draw_indexed)(WGPURenderBundleEncoder renderBundleEncoder, uint32_t indexCount, uint32_t instanceCount, uint32_t firstIndex, int32_t baseVertex, uint32_t firstInstance);
	void (*wgpu_render_bundle_encoder_draw_indexed_indirect)(WGPURenderBundleEncoder renderBundleEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
	void (*wgpu_render_bundle_encoder_draw_indirect)(WGPURenderBundleEncoder renderBundleEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
	WGPURenderBundle (*wgpu_render_bundle_encoder_finish)(WGPURenderBundleEncoder renderBundleEncoder, WGPURenderBundleDescriptor const* descriptor /* nullable */);
	void (*wgpu_render_bundle_encoder_insert_debug_marker)(WGPURenderBundleEncoder renderBundleEncoder, char const* markerLabel);
	void (*wgpu_render_bundle_encoder_pop_debug_group)(WGPURenderBundleEncoder renderBundleEncoder);
	void (*wgpu_render_bundle_encoder_push_debug_group)(WGPURenderBundleEncoder renderBundleEncoder, char const* groupLabel);
	void (*wgpu_render_bundle_encoder_set_bind_group)(WGPURenderBundleEncoder renderBundleEncoder, uint32_t groupIndex, WGPUBindGroup group, uint32_t dynamicOffsetCount, uint32_t const* dynamicOffsets);
	void (*wgpu_render_bundle_encoder_set_index_buffer)(WGPURenderBundleEncoder renderBundleEncoder, WGPUBuffer buffer, WGPUIndexFormat format, uint64_t offset, uint64_t size);
	void (*wgpu_render_bundle_encoder_set_label)(WGPURenderBundleEncoder renderBundleEncoder, char const* label);
	void (*wgpu_render_bundle_encoder_set_pipeline)(WGPURenderBundleEncoder renderBundleEncoder, WGPURenderPipeline pipeline);
	void (*wgpu_render_bundle_encoder_set_vertex_buffer)(WGPURenderBundleEncoder renderBundleEncoder, uint32_t slot, WGPUBuffer buffer, uint64_t offset, uint64_t size);
	void (*wgpu_render_pass_encoder_begin_occlusion_query)(WGPURenderPassEncoder renderPassEncoder, uint32_t queryIndex);
	void (*wgpu_render_pass_encoder_begin_pipeline_statistics_query)(WGPURenderPassEncoder renderPassEncoder, WGPUQuerySet querySet, uint32_t queryIndex);
	void (*wgpu_render_pass_encoder_draw)(WGPURenderPassEncoder renderPassEncoder, uint32_t vertexCount, uint32_t instanceCount, uint32_t firstVertex, uint32_t firstInstance);
	void (*wgpu_render_pass_encoder_draw_indexed)(WGPURenderPassEncoder renderPassEncoder, uint32_t indexCount, uint32_t instanceCount, uint32_t firstIndex, int32_t baseVertex, uint32_t firstInstance);
	void (*wgpu_render_pass_encoder_draw_indexed_indirect)(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
	void (*wgpu_render_pass_encoder_draw_indirect)(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer indirectBuffer, uint64_t indirectOffset);
	void (*wgpu_render_pass_encoder_end)(WGPURenderPassEncoder renderPassEncoder);
	void (*wgpu_render_pass_encoder_end_occlusion_query)(WGPURenderPassEncoder renderPassEncoder);
	void (*wgpu_render_pass_encoder_end_pipeline_statistics_query)(WGPURenderPassEncoder renderPassEncoder);
	void (*wgpu_render_pass_encoder_execute_bundles)(WGPURenderPassEncoder renderPassEncoder, uint32_t bundleCount, WGPURenderBundle const* bundles);
	void (*wgpu_render_pass_encoder_insert_debug_marker)(WGPURenderPassEncoder renderPassEncoder, char const* markerLabel);
	void (*wgpu_render_pass_encoder_pop_debug_group)(WGPURenderPassEncoder renderPassEncoder);
	void (*wgpu_render_pass_encoder_push_debug_group)(WGPURenderPassEncoder renderPassEncoder, char const* groupLabel);
	void (*wgpu_render_pass_encoder_set_bind_group)(WGPURenderPassEncoder renderPassEncoder, uint32_t groupIndex, WGPUBindGroup group, uint32_t dynamicOffsetCount, uint32_t const* dynamicOffsets);
	void (*wgpu_render_pass_encoder_set_blend_constant)(WGPURenderPassEncoder renderPassEncoder, WGPUColor const* color);
	void (*wgpu_render_pass_encoder_set_index_buffer)(WGPURenderPassEncoder renderPassEncoder, WGPUBuffer buffer, WGPUIndexFormat format, uint64_t offset, uint64_t size);
	void (*wgpu_render_pass_encoder_set_label)(WGPURenderPassEncoder renderPassEncoder, char const* label);
	void (*wgpu_render_pass_encoder_set_pipeline)(WGPURenderPassEncoder renderPassEncoder, WGPURenderPipeline pipeline);
	void (*wgpu_render_pass_encoder_set_scissor_rect)(WGPURenderPassEncoder renderPassEncoder, uint32_t x, uint32_t y, uint32_t width, uint32_t height);
	void (*wgpu_render_pass_encoder_set_stencil_reference)(WGPURenderPassEncoder renderPassEncoder, uint32_t reference);
	void (*wgpu_render_pass_encoder_set_vertex_buffer)(WGPURenderPassEncoder renderPassEncoder, uint32_t slot, WGPUBuffer buffer, uint64_t offset, uint64_t size);
	void (*wgpu_render_pass_encoder_set_viewport)(WGPURenderPassEncoder renderPassEncoder, float x, float y, float width, float height, float minDepth, float maxDepth);
	WGPUBindGroupLayout (*wgpu_render_pipeline_get_bind_group_layout)(WGPURenderPipeline renderPipeline, uint32_t groupIndex);
	void (*wgpu_render_pipeline_set_label)(WGPURenderPipeline renderPipeline, char const* label);
	void (*wgpu_sampler_set_label)(WGPUSampler sampler, char const* label);
	void (*wgpu_shader_module_get_compilation_info)(WGPUShaderModule shaderModule, WGPUCompilationInfoCallback callback, void* userdata);
	void (*wgpu_shader_module_set_label)(WGPUShaderModule shaderModule, char const* label);
	WGPUTextureFormat (*wgpu_surface_get_preferred_format)(WGPUSurface surface, WGPUAdapter adapter);
	WGPUTextureView (*wgpu_swapchain_get_current_texture_view)(WGPUSwapChain swapChain);
	void (*wgpu_swapchain_present)(WGPUSwapChain swapChain);
	WGPUTextureView (*wgpu_texture_create_view)(WGPUTexture texture, WGPUTextureViewDescriptor const* descriptor /* nullable */);
	void (*wgpu_texture_destroy)(WGPUTexture texture);
	uint32_t (*wgpu_texture_get_depth_or_array_layers)(WGPUTexture texture);
	WGPUTextureDimension (*wgpu_texture_get_dimension)(WGPUTexture texture);
	WGPUTextureFormat (*wgpu_texture_get_format)(WGPUTexture texture);
	uint32_t (*wgpu_texture_get_height)(WGPUTexture texture);
	uint32_t (*wgpu_texture_get_mip_level_count)(WGPUTexture texture);
	uint32_t (*wgpu_texture_get_sample_count)(WGPUTexture texture);
	WGPUTextureUsage (*wgpu_texture_get_usage)(WGPUTexture texture);
	uint32_t (*wgpu_texture_get_width)(WGPUTexture texture);
	void (*wgpu_texture_set_label)(WGPUTexture texture, char const* label);
	void (*wgpu_texture_view_set_label)(WGPUTextureView textureView, char const* label);
};

namespace webgpu_ffi {
	void* getExportsTable();
}